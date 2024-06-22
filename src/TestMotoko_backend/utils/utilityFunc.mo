import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Bool "mo:base/Bool";
import Array "mo:base/Array";
import DateTime "mo:datetime/DateTime";
import uuid "mo:uuid/UUID";
import Source "mo:uuid/async/SourceV4";

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

    public func getUuid() : async Text {
        let g = Source.Source();
        uuid.toText(await g.new());
    };
    public func validText(text : Text, value : Nat) : Bool {
        if (Text.size(text) >= value or Text.size(text) == 0) {
            return false;
        };
        true;
    };

};
