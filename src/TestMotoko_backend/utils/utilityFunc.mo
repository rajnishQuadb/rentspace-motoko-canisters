import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Bool "mo:base/Bool";
import Array "mo:base/Array";
import DateTime "mo:datetime/DateTime";

module {
    public func checkAnonymous(_caller : Principal) : async () {
        if (Principal.isAnonymous(_caller)) {
            let err = Error.reject("Anonymous users are forbidden to access this resource");
            throw err;
        };
    };

    public func getDate() : Text {
        let timeNow : DateTime.DateTime = DateTime.DateTime(Time.now());
        let date = DateTime.toText(timeNow);
        return date;
    };

    public func getAdminFromArray(caller : Principal, admin : [Text]) : async Bool {
        switch (Array.find<Text>(admin, func(x) : Bool { x == Principal.toText(caller) })) {
            case (null) {
                return false;
            };
            case (?r) {
                return true;
            };
        };
    };

};
