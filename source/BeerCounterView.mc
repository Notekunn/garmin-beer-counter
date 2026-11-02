import Toybox.ActivityMonitor;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

const COLOR_BEER = 0xF2A71B;
const COLOR_BEER_SHINE = 0xFFD36B;
const COLOR_FOAM = 0xFFF6DD;
const COLOR_TITLE = 0xFFC53D;

class BeerCounterView extends WatchUi.View {
    const UNDO_MS = 5000;
    const HIT_MS = 2500;
    const UNDO_STRIP_RATIO = 0.79;
    const TICK_FAST_MS = 50;
    const TICK_SLOW_MS = 1000;
    const STAT_GAP = 12;
    const STAT_ICON_GAP = 4;

    private var _session as BeerSession;
    private var _timer as Timer.Timer;
    private var _tickMs as Number = 0;
    private var _fill as Float = 0.0;
    private var _undoUntil as Number = 0;
    private var _hitUntil as Number = 0;
    private var _hr as Number? = null;
    private var _stress as Number? = null;
    private var _stripY as Number = 0;
    private var _iconClock as BitmapResource;
    private var _iconRate as BitmapResource;
    private var _iconHeart as BitmapResource;
    private var _iconStress as BitmapResource;

    function initialize() {
        View.initialize();
        _iconClock = WatchUi.loadResource(Rez.Drawables.IconClock) as BitmapResource;
        _iconRate = WatchUi.loadResource(Rez.Drawables.IconRate) as BitmapResource;
        _iconHeart = WatchUi.loadResource(Rez.Drawables.IconHeart) as BitmapResource;
        _iconStress = WatchUi.loadResource(Rez.Drawables.IconStress) as BitmapResource;
        _session = new BeerSession();
        _session.load(now());
        _timer = new Timer.Timer();
        _fill = _session.fillRatio();
    }

    function onLayout(dc as Dc) as Void {
        _stripY = (dc.getHeight() * UNDO_STRIP_RATIO).toNumber();
    }

    function onShow() as Void {
        _stress = readStress();
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
        setTick(TICK_SLOW_MS);
    }

    function onHide() as Void {
        Sensor.enableSensorEvents(null);
        Sensor.setEnabledSensors([]);
        _timer.stop();
        _tickMs = 0;
    }

    function onSensor(info as Sensor.Info) as Void {
        _stress = readStress();
        _hr = info.heartRate;
        if (_hr != null) {
            _session.noteHeartRate(_hr);
        }
    }

    function onTick() as Void {
        var target = _session.fillRatio();
        var gap = target - _fill;
        var animating = gap > 0.002 || gap < -0.002;
        _fill = animating ? _fill + gap * 0.3 : target;
        var nowMs = System.getTimer();
        if (_undoUntil != 0 && nowMs >= _undoUntil) {
            _undoUntil = 0;
        }
        if (_hitUntil != 0 && nowMs >= _hitUntil) {
            _hitUntil = 0;
        }
        setTick(animating || _undoUntil != 0 || _hitUntil != 0 ? TICK_FAST_MS : TICK_SLOW_MS);
        WatchUi.requestUpdate();
    }

    function handleTap(y as Number) as Void {
        if (_session.isEnded()) {
            handleSelect();
        } else if (_undoUntil != 0 && y >= _stripY) {
            undo();
        } else {
            add();
        }
    }

    function handleSelect() as Void {
        if (_session.isEnded()) {
            confirm("New session?", method(:newSession));
        } else {
            confirm("End session?", method(:endSession));
        }
    }

    function endSession() as Void {
        _undoUntil = 0;
        _hitUntil = 0;
        _session.end(now());
        WatchUi.requestUpdate();
    }

    function newSession() as Void {
        _session.reset();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        if (_session.isEnded()) {
            drawSummary(dc);
        } else {
            drawMain(dc);
        }
    }

    private function add() as Void {
        _session.add(now());
        var nowMs = System.getTimer();
        _undoUntil = nowMs + UNDO_MS;
        _hitUntil = _session.isMilestone() ? nowMs + HIT_MS : 0;
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(60, 150)]);
        }
        setTick(TICK_FAST_MS);
        WatchUi.requestUpdate();
    }

    private function undo() as Void {
        _session.undo();
        _undoUntil = 0;
        _hitUntil = 0;
        setTick(TICK_FAST_MS);
        WatchUi.requestUpdate();
    }

    private function confirm(message as String, onYes as Method() as Void) as Void {
        WatchUi.pushView(
            new WatchUi.Confirmation(message),
            new SessionConfirmDelegate(onYes),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    private function setTick(ms as Number) as Void {
        if (_tickMs != ms) {
            _timer.stop();
            _timer.start(method(:onTick), ms, true);
            _tickMs = ms;
        }
    }

    private function drawMain(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        drawMug(dc, w / 2, (h * 0.10).toNumber(), (h * 0.27).toNumber());

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, w / 2, (h * 0.49).toNumber(), Graphics.FONT_NUMBER_MEDIUM, _session.count.toString());

        var hit = _hitUntil != 0;
        dc.setColor(COLOR_TITLE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, w / 2, (h * 0.62).toNumber(), hit ? Graphics.FONT_MEDIUM : Graphics.FONT_TINY, _session.title());

        drawStats(dc, (h * 0.72).toNumber(), [
            [_iconClock, timeText()],
            [_iconRate, rateText()],
            [_iconHeart, numberText(_hr)],
            [_iconStress, numberText(_stress)]
        ]);

        if (_undoUntil != 0) {
            drawUndoStrip(dc, w, h);
        }
    }

    private function drawSummary(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, w / 2, (h * 0.15).toNumber(), Graphics.FONT_XTINY, "SESSION COMPLETE");
        dc.setColor(COLOR_TITLE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, w / 2, (h * 0.34).toNumber(), Graphics.FONT_NUMBER_HOT, _session.count.toString());
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, w / 2, (h * 0.51).toNumber(), Graphics.FONT_TINY, "beers");
        dc.setColor(COLOR_TITLE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, w / 2, (h * 0.63).toNumber(), Graphics.FONT_SMALL, _session.title());
        var maxHr = _session.maxHr == 0 ? null : _session.maxHr;
        drawStats(dc, (h * 0.77).toNumber(), [[_iconClock, timeText()], [_iconRate, rateText()]]);
        drawStats(dc, (h * 0.85).toNumber(), [[_iconHeart, "max " + numberText(maxHr)], [_iconStress, numberText(_stress)]]);
    }

    // Each item is [icon, text]; the row is centred as a group so it stays inside the round screen.
    private function drawStats(dc as Dc, y as Number, items as Array<Array>) as Void {
        var font = Graphics.FONT_XTINY;
        var total = (items.size() - 1) * STAT_GAP;
        for (var i = 0; i < items.size(); i += 1) {
            var icon = items[i][0] as BitmapResource;
            total += icon.getWidth() + STAT_ICON_GAP + dc.getTextWidthInPixels(items[i][1] as String, font);
        }
        var x = (dc.getWidth() - total) / 2;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < items.size(); i += 1) {
            var icon = items[i][0] as BitmapResource;
            var text = items[i][1] as String;
            dc.drawBitmap(x, y - icon.getHeight() / 2, icon);
            x += icon.getWidth() + STAT_ICON_GAP;
            dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            x += dc.getTextWidthInPixels(text, font) + STAT_GAP;
        }
    }

    private function drawUndoStrip(dc as Dc, w as Number, h as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, _stripY, w, h - _stripY);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var left = (_undoUntil - System.getTimer() + 999) / 1000;
        drawCentered(dc, w / 2, _stripY + (h - _stripY) / 3, Graphics.FONT_TINY, "UNDO " + left + "s");
    }

    private function drawMug(dc as Dc, cx as Number, top as Number, height as Number) as Void {
        var mugW = (height * 0.74).toNumber();
        var left = cx - mugW / 2 - height / 10;
        var radius = height / 5;
        var pen = 5;
        var inset = pen + 2;
        var innerW = mugW - inset * 2;
        var maxBeerH = height - inset * 2;
        var beerH = (maxBeerH * _fill).toNumber();
        var bottom = top + height - inset;

        dc.setAntiAlias(true);
        dc.setPenWidth(9);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(left + mugW, top + height / 2, height / 4, Graphics.ARC_CLOCKWISE, 90, 270);

        dc.setPenWidth(pen);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(left, top, mugW, height, radius);

        if (beerH > 0) {
            var beerTop = bottom - beerH;
            var beerRadius = radius - inset;
            dc.setColor(COLOR_BEER, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(left + inset, beerTop, innerW, beerH, beerRadius < beerH / 2 ? beerRadius : beerH / 2);
            if (beerH > 36) {
                dc.setColor(COLOR_BEER_SHINE, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(left + inset + 8, beerTop + 14, 6, beerH - 28, 3);
            }
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(left, top, mugW, height, radius);

        if (beerH > 0) {
            var bubbleR = innerW / 7;
            dc.setColor(COLOR_FOAM, Graphics.COLOR_TRANSPARENT);
            for (var i = 0; i < 4; i += 1) {
                dc.fillCircle(left + inset + (2 * i + 1) * innerW / 8, bottom - beerH, bubbleR);
            }
        }

        dc.setPenWidth(1);
        dc.setAntiAlias(false);
    }

    private function drawCentered(dc as Dc, x as Number, y as Number, font as Graphics.FontType, text as String) as Void {
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function timeText() as String {
        var minutes = _session.elapsedSeconds(now()) / 60;
        return (minutes / 60) + "h" + (minutes % 60).format("%02d");
    }

    private function rateText() as String {
        var rate = _session.ratePerHour(now());
        return (rate == null ? "--" : rate.format("%.1f")) + "/h";
    }

    private function numberText(value as Number?) as String {
        return value == null ? "--" : value.toString();
    }

    private function readStress() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info has :stressScore) {
            var score = info.stressScore;
            if (score != null && score >= 0 && score <= 100) {
                return score;
            }
        }
        return null;
    }

    private function now() as Number {
        return Time.now().value();
    }
}

class BeerCounterDelegate extends WatchUi.InputDelegate {
    private var _view as BeerCounterView;

    function initialize(view as BeerCounterView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onTap(event as WatchUi.ClickEvent) as Boolean {
        _view.handleTap(event.getCoordinates()[1]);
        return true;
    }

    // Back is left unhandled on purpose: it exits and the count stays in storage.
    function onKey(event as WatchUi.KeyEvent) as Boolean {
        if (event.getKey() == WatchUi.KEY_ENTER) {
            _view.handleSelect();
            return true;
        }
        return false;
    }
}

class SessionConfirmDelegate extends WatchUi.ConfirmationDelegate {
    private var _onYes as Method() as Void;

    function initialize(onYes as Method() as Void) {
        ConfirmationDelegate.initialize();
        _onYes = onYes;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _onYes.invoke();
        }
        return true;
    }
}
