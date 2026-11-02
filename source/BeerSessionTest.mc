import Toybox.Lang;
import Toybox.Test;

(:test)
function addStartsSessionAndUndoClearsIt(logger as Test.Logger) as Boolean {
    var s = new BeerSession();
    s.reset();
    s.add(1000);
    s.add(1600);
    s.undo();
    Test.assertEqual(s.count, 1);
    Test.assertEqual(s.lastAt, 1000);
    s.undo();
    Test.assertEqual(s.count, 0);
    Test.assertEqual(s.startAt, 0);
    s.undo();
    Test.assertEqual(s.count, 0);
    return true;
}

(:test)
function countSurvivesReload(logger as Test.Logger) as Boolean {
    var s = new BeerSession();
    s.reset();
    s.add(1000);
    s.add(1100);
    var reopened = new BeerSession();
    reopened.load(1200);
    Test.assertEqual(reopened.count, 2);
    Test.assertEqual(reopened.startAt, 1000);
    return true;
}

(:test)
function autoResetsOnlyAfterTwelveHours(logger as Test.Logger) as Boolean {
    var twelveHours = 12 * 60 * 60;
    var s = new BeerSession();
    s.reset();
    s.add(1000);
    var early = new BeerSession();
    early.load(1000 + twelveHours - 1);
    Test.assertEqual(early.count, 1);
    var late = new BeerSession();
    late.load(1000 + twelveHours);
    Test.assertEqual(late.count, 0);
    return true;
}

(:test)
function rateHiddenForFirstFifteenMinutes(logger as Test.Logger) as Boolean {
    var s = new BeerSession();
    s.reset();
    s.add(1000);
    s.add(1000);
    s.add(1000);
    Test.assert(s.ratePerHour(1000 + 899) == null);
    Test.assertEqual(s.ratePerHour(1000 + 3600), 3.0);
    return true;
}

(:test)
function elapsedFreezesWhenSessionEnds(logger as Test.Logger) as Boolean {
    var s = new BeerSession();
    s.reset();
    s.add(1000);
    s.end(2000);
    Test.assertEqual(s.elapsedSeconds(9000), 1000);
    return true;
}

(:test)
function titlesFollowMilestones(logger as Test.Logger) as Boolean {
    var s = new BeerSession();
    s.reset();
    Test.assertEqual(s.title(), "Tap to pour");
    s.end(1000);
    Test.assertEqual(s.title(), "Designated Driver");
    s.reset();
    var expected = {1 => "Warming Up", 3 => "Getting Loose", 5 => "Beer Apprentice", 8 => "Table Captain", 10 => "Beer Legend", 15 => "Send Help"};
    for (var i = 1; i <= 15; i += 1) {
        s.add(1000);
        var title = expected[i];
        Test.assertEqual(s.isMilestone(), title != null);
        if (title != null) {
            Test.assertEqual(s.title(), title);
        }
    }
    return true;
}

(:test)
function mugStopsFillingAtTen(logger as Test.Logger) as Boolean {
    var s = new BeerSession();
    s.reset();
    for (var i = 0; i < 12; i += 1) {
        s.add(1000);
    }
    Test.assertEqual(s.fillRatio(), 1.0);
    return true;
}

(:test)
function maxHeartRateTracksActiveSessionOnly(logger as Test.Logger) as Boolean {
    var s = new BeerSession();
    s.reset();
    s.noteHeartRate(90);
    Test.assertEqual(s.maxHr, 0);
    s.add(1000);
    s.noteHeartRate(90);
    s.noteHeartRate(80);
    Test.assertEqual(s.maxHr, 90);
    s.end(2000);
    s.noteHeartRate(120);
    Test.assertEqual(s.maxHr, 90);
    return true;
}
