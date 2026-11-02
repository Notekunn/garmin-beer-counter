import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class BeerCounterApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new BeerCounterView();
        return [view, new BeerCounterDelegate(view)];
    }
}
