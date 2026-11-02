import Toybox.Application;
import Toybox.Lang;

// All timestamps are epoch seconds, 0 means "not set".
class BeerSession {
    const STORAGE_KEY = "session";
    const AUTO_RESET_SECONDS = 12 * 60 * 60;
    const RATE_MIN_SECONDS = 15 * 60;
    const FULL_MUG_COUNT = 10;

    var count as Number = 0;
    var startAt as Number = 0;
    var lastAt as Number = 0;
    var endAt as Number = 0;
    var maxHr as Number = 0;

    private var _prevLastAt as Number = 0;

    function initialize() {
    }

    function load(now as Number) as Void {
        var saved = Application.Storage.getValue(STORAGE_KEY) as Array<Number>?;
        if (saved != null && saved.size() == 5) {
            count = saved[0];
            startAt = saved[1];
            lastAt = saved[2];
            endAt = saved[3];
            maxHr = saved[4];
        }
        if (isExpired(now)) {
            reset();
        }
    }

    function isExpired(now as Number) as Boolean {
        return lastAt != 0 && now - lastAt >= AUTO_RESET_SECONDS;
    }

    function add(now as Number) as Void {
        count += 1;
        if (startAt == 0) {
            startAt = now;
        }
        _prevLastAt = lastAt;
        lastAt = now;
        save();
    }

    function undo() as Void {
        if (count == 0) {
            return;
        }
        count -= 1;
        lastAt = _prevLastAt;
        if (count == 0) {
            startAt = 0;
            maxHr = 0;
        }
        save();
    }

    function end(now as Number) as Void {
        endAt = now;
        save();
    }

    function reset() as Void {
        count = 0;
        startAt = 0;
        lastAt = 0;
        endAt = 0;
        maxHr = 0;
        _prevLastAt = 0;
        save();
    }

    function noteHeartRate(hr as Number) as Void {
        if (startAt != 0 && !isEnded() && hr > maxHr) {
            maxHr = hr;
            save();
        }
    }

    function isEnded() as Boolean {
        return endAt != 0;
    }

    function fillRatio() as Float {
        var capped = count < FULL_MUG_COUNT ? count : FULL_MUG_COUNT;
        return capped.toFloat() / FULL_MUG_COUNT;
    }

    function elapsedSeconds(now as Number) as Number {
        if (startAt == 0) {
            return 0;
        }
        return (isEnded() ? endAt : now) - startAt;
    }

    // Null until enough time has passed for the number to mean anything.
    function ratePerHour(now as Number) as Float? {
        var elapsed = elapsedSeconds(now);
        if (elapsed < RATE_MIN_SECONDS) {
            return null;
        }
        return count * 3600.0 / elapsed;
    }

    function title() as String {
        if (count == 0) {
            return isEnded() ? "Designated Driver" : "Tap to pour";
        }
        return titleFor(count) as String;
    }

    function isMilestone() as Boolean {
        var milestones = [1, 3, 5, 8, 10, 15];
        return milestones.indexOf(count) != -1;
    }

    private function titleFor(cups as Number) as String {
        if (cups >= 15) {
            return "Send Help";
        } else if (cups >= 10) {
            return "Beer Legend";
        } else if (cups >= 8) {
            return "Table Captain";
        } else if (cups >= 5) {
            return "Beer Apprentice";
        } else if (cups >= 3) {
            return "Getting Loose";
        }
        return "Warming Up";
    }

    private function save() as Void {
        Application.Storage.setValue(STORAGE_KEY, [count, startAt, lastAt, endAt, maxHr]);
    }
}
