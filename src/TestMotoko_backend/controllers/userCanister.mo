import UserModal "../modals/userModal";
import UtilityFunc "../utils/utilityFunc";

import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Error "mo:base/Error";
// import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Char "mo:base/Char";
import Bool "mo:base/Bool";
import DateTime "mo:datetime/DateTime";
import Month "../utils/month";
// import UserTypes "../types/userTypes";

shared ({ caller = owner }) actor class User() {
    var userRecord = TrieMap.TrieMap<Principal, UserModal.UserInfo>(Principal.equal, Principal.hash);
    var anualRegisterFrequency = TrieMap.TrieMap<UserModal.Year, UserModal.AnnualData>(Text.equal, Text.hash);
    var admin : [UserModal.AdminId] = []; // make it stable array for main net

    // Register a new user
    public shared ({ caller }) func registerUser(userData : UserModal.User) : async Result.Result<Text, Text> {
        try {
            await UtilityFunc.checkAnonymous(caller);
            switch (userRecord.get(caller)) {
                case (null) {

                    let currentDate = UtilityFunc.getDate();

                    // anual register frequency update
                    let date = DateTime.DateTime(Time.now()).toText();
                    var counter = 0;
                    var year = "";
                    var month = "";

                    for (i in Text.toIter(date)) {
                        if (counter <= 3) {
                            year := year # Char.toText(i);
                        };
                        if (counter > 5 and counter <= 6) {
                            month := month # Char.toText(i);
                        };
                        counter += 1;
                    };

                    switch (anualRegisterFrequency.get(year)) {
                        case (null) {
                            let intialAnnualData = {
                                jan = 0;
                                feb = 0;
                                march = 0;
                                april = 0;
                                may = 0;
                                june = 0;
                                july = 0;
                                aug = 0;
                                sep = 0;
                                oct = 0;
                                nov = 0;
                                dec = 0;
                            };
                            let monthData = Month.updateMonthData(month, intialAnnualData);
                            anualRegisterFrequency.put(year, monthData);

                        };
                        case (?result) {
                            let updateMothData = Month.updateMonthData(month, result);
                            ignore anualRegisterFrequency.replace(year, updateMothData);
                        };
                    };

                    //----------------------
                    let newUser : UserModal.UserInfo = {
                        userID = caller;
                        firstName = userData.firstName;
                        lastName = userData.lastName;
                        dob = userData.dob;
                        userEmail = userData.userEmail;
                        userRole = "user";
                        userImage = "";
                        userGovID = "";
                        govIDLink = "";
                        isHost = false;
                        isVerified = false;
                        agreementStatus = false;
                        createdAt = currentDate;
                    };
                    userRecord.put(caller, newUser);

                    return #ok("User registered successfully");
                };
                case (?user) {
                    return #err("User already registered");
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // Get user details
    public shared ({ caller }) func getuserDetails() : async Result.Result<UserModal.UserInfo, Text> {
        try {
            await UtilityFunc.checkAnonymous(caller);
            switch (userRecord.get(caller)) {
                case (null) {
                    return #err("User not found");
                };
                case (?user) {
                    return #ok(user);
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // Update user details
    public shared ({ caller }) func updateUserDetails(userData : UserModal.UserInfo) : async Result.Result<Text, Text> {
        try {
            await UtilityFunc.checkAnonymous(caller);
            switch (userRecord.get(caller)) {
                case (null) {
                    return #err("User not found");
                };
                case (?user) {
                    let updateData : UserModal.UserInfo = {
                        userID = caller;
                        firstName = userData.firstName;
                        lastName = userData.lastName;
                        dob = userData.dob;
                        userEmail = userData.userEmail;
                        userRole = userData.userRole;
                        userImage = userData.userImage;
                        userGovID = userData.userGovID;
                        govIDLink = userData.govIDLink;
                        isHost = true;
                        isVerified = true;
                        agreementStatus = false;
                        createdAt = userData.createdAt;
                    };
                    ignore userRecord.replace(caller, updateData);
                    return #ok("User details updated successfully");
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // Delete user details
    public shared ({ caller }) func deleteUser() : async Result.Result<Text, Text> {
        try {
            await UtilityFunc.checkAnonymous(caller);
            switch (userRecord.get(caller)) {
                case (null) {
                    return #err("User not found");
                };
                case (?user) {
                    userRecord.delete(caller);
                    return #ok("User deleted successfully");
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // Get user by Principal
    public func getUserByPrincipal(principal : Principal) : async Result.Result<UserModal.UserInfo, Text> {
        try {
            switch (userRecord.get(principal)) {
                case (null) {
                    return #err("User not found");
                };
                case (?user) {
                    return #ok(user);
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // Get anual registered users
    public shared ({ caller }) func getAnnualRegisterByYear(year : Text) : async Result.Result<UserModal.AnnualData, Text> {
        try {
            let isAdmin = await UtilityFunc.getAdminFromArray(caller, admin);
            if (isAdmin == false) {
                return #err("User not authorized to access this data");
            };
            switch (anualRegisterFrequency.get(year)) {
                case (null) {
                    return #err("No user registered in this year");
                };
                case (?data) {
                    return #ok(data);
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // Whoami function
    public shared ({ caller }) func whoami() : async Text {
        // Principal.toText(caller);
        return Principal.toText(caller);
    };

    // check User Exist
    public query func checkUserExist(userId : Text) : async Bool {
        switch (userRecord.get(Principal.fromText(userId))) {
            case (null) {
                return false;
            };
            case (?user) {
                return true;
            };
        };
    };

};
