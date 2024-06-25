import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Char "mo:base/Char";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import DateTime "mo:datetime/DateTime";
import UtilityFunc "../utils/utilityFunc";
import Month "../utils/month";
import HotelTypes "../types/hotelTypes";

shared ({ caller = owner }) actor class () {

    // var userCanisterID = "bd3sg-teaaa-aaaaa-qaaba-cai";

    var hotelRecord = TrieMap.TrieMap<HotelTypes.HotelId, HotelTypes.HotelInfo>(Text.equal, Text.hash);
    var hotelIdMap = TrieMap.TrieMap<HotelTypes.UserId, [HotelTypes.HotelId]>(Text.equal, Text.hash);
    var hotelRegisterFrequencyMap = TrieMap.TrieMap<HotelTypes.Year, HotelTypes.AnnualData>(Text.equal, Text.hash);
    // var admin : [HotelTypes.AdminId] = []; // make it stable array for main net

    var hotelRoomRecord = TrieMap.TrieMap<HotelTypes.HotelId, HotelTypes.RoomType>(Text.equal, Text.hash);

    // creating refrence for user canister
    // let userActor = actor (userCanisterID) : actor {
    //     checkUserExist : query (Text) -> async (Bool);
    // };

    func hotelValidator(hotelData : HotelTypes.HotelInfo) {
        if (
            UtilityFunc.validText(hotelData.hotelTitle, 40) == false or
            UtilityFunc.validText(hotelData.hotelDes, 300) == false or
            UtilityFunc.validText(hotelData.hotelLocation, 30) == false
        ) {
            Debug.trap("Invalid Hotel Data");
        };
    };

    // create hotel
    public shared ({ caller }) func createHotel(hotelData : HotelTypes.HotelInfo, roomData : HotelTypes.RoomType) : async Result.Result<Text, Text> {
        try {
            await UtilityFunc.checkAnonymous(caller);
            hotelValidator(hotelData);

            let userIdentity = Principal.toText(caller);
            // let isUserExist = await userActor.checkUserExist(userIdentity);
            // if (isUserExist == false) {
            //     // throw "User Not Exist";
            //     return #err("User Not Exist");
            // };

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

            switch (hotelRegisterFrequencyMap.get(year)) {
                case (null) {
                    let initialAnnualData = {
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
                    let monthData = Month.updateMonthData(month, initialAnnualData);
                    hotelRegisterFrequencyMap.put(year, monthData);

                };
                case (?result) {
                    let updatedMonthData = Month.updateMonthData(month, result);
                    ignore hotelRegisterFrequencyMap.replace(year, updatedMonthData);
                };
            };

            // hotel ID creation
            let uuid = await UtilityFunc.getUuid();
            let hotelId : HotelTypes.HotelId = userIdentity # "#" # uuid;

            // update hotelIdMap with new hotelId
            switch (hotelIdMap.get(userIdentity)) {
                case (null) {
                    hotelIdMap.put(userIdentity, [hotelId]);
                };
                case (?result) {
                    var updatedHotelIdList : Buffer.Buffer<Text> = Buffer.fromArray(result);
                    updatedHotelIdList.add(hotelId);
                    ignore hotelIdMap.replace(userIdentity, Buffer.toArray(updatedHotelIdList));
                };
            };

            let getDate = UtilityFunc.getDate();

            let newHotelInfo : HotelTypes.HotelInfo = {
                hotelId = hotelId;
                hotelTitle = hotelData.hotelTitle;
                hotelDes = hotelData.hotelDes;
                hotelImage = hotelData.hotelImage;
                hotelLocation = hotelData.hotelLocation;
                hotelAvailableFrom = hotelData.hotelAvailableFrom;
                hotelAvailableTill = hotelData.hotelAvailableTill;
                createdAt = getDate;
            };

            hotelRecord.put(hotelId, newHotelInfo);
            hotelRoomRecord.put(hotelId, roomData);

            return #ok("Hotel Created Successfully" # " ==> " # hotelId);

        } catch e {
            return #err(Error.message(e));
        };
    };

    // get hotel by hotelId
    public query func getHotel(hotelId : HotelTypes.HotelId) : async Result.Result<HotelTypes.HotelInfo, Text> {
        try {
            switch (hotelRecord.get(hotelId)) {
                case (null) {
                    return #err("Hotel Not Found");
                };
                case (?result) {
                    return #ok(result);
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // get room by hotelId
    public query func getRoom(hotelId : HotelTypes.HotelId) : async Result.Result<HotelTypes.RoomType, Text> {
        try {
            switch (hotelRoomRecord.get(hotelId)) {
                case (null) {
                    return #err("Room Not Found");
                };
                case (?result) {
                    return #ok(result);
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // update hotel
    public shared ({ caller }) func updateHotel(hotelData : HotelTypes.HotelInfo, roomData : HotelTypes.RoomType) : async Result.Result<Text, Text> {
        try {
            await UtilityFunc.checkAnonymous(caller);
            hotelValidator(hotelData);

            let userIdentity = Principal.toText(caller);
            // let isUserExist = await userActor.checkUserExist(userIdentity);
            // if (isUserExist == false) {
            //     return #err("User Not Exist");
            // };

            switch (hotelRecord.get(hotelData.hotelId)) {
                case (null) {
                    return #err("Hotel Not Found" # " ==> " # hotelData.hotelId);
                };
                case (?r) {
                    let updatedHotelInfo : HotelTypes.HotelInfo = {
                        hotelId = r.hotelId;
                        hotelTitle = hotelData.hotelTitle;
                        hotelDes = hotelData.hotelDes;
                        hotelImage = hotelData.hotelImage;
                        hotelLocation = hotelData.hotelLocation;
                        hotelAvailableFrom = hotelData.hotelAvailableFrom;
                        hotelAvailableTill = hotelData.hotelAvailableTill;
                        createdAt = hotelData.createdAt;
                    };

                    // update room data
                    ignore hotelRoomRecord.replace(hotelData.hotelId, roomData);

                    ignore hotelRecord.replace(hotelData.hotelId, updatedHotelInfo);

                    return #ok("Hotel Updated Successfully" # " ==> " # hotelData.hotelId);
                };

            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // delete hotel
    public shared ({ caller }) func deleteHotel(hotelId : HotelTypes.HotelId) : async Result.Result<Text, Text> {
        try {
            await UtilityFunc.checkAnonymous(caller);

            switch (hotelRecord.get(hotelId)) {
                case (null) {
                    return #err("Hotel Not Found");
                };
                case (?result) {
                    ignore hotelRecord.remove(hotelId);
                    ignore hotelRoomRecord.remove(hotelId);

                    // let userIdentity = Principal.toText(caller);
                    // switch(hotelIdMap.get(userIdentity)){
                    //     case(null){
                    //         return #err("No Hotel Found for this User");
                    //     };
                    //     case(?result){
                    //         var updatedHotelIdList : Buffer.Buffer<Text> = Buffer.fromArray(result);
                    //         updatedHotelIdList.remove(hotelId);
                    //         ignore hotelIdMap.replace(userIdentity, Buffer.toArray(updatedHotelIdList));
                    //     };
                    // };

                    return #ok("Hotel Deleted Successfully");
                };
            };

        } catch e {
            return #err(Error.message(e));
        };
    };

    // get Hotel Register Frequency Data
    public query func getHotelRegisterFrequencyData(year : HotelTypes.Year) : async Result.Result<HotelTypes.AnnualData, Text> {
        try {
            switch (hotelRegisterFrequencyMap.get(year)) {
                case (null) {
                    return #err("Data Not Found");
                };
                case (?result) {
                    return #ok(result);
                };
            };
        } catch e {
            return #err(Error.message(e));
        };
    };

    // whoami
    public shared ({ caller }) func whoami() : async Text {
        return Principal.toText(caller);
    };

    // chechHotelExist
    public query func checkHotelExist(hotelId : HotelTypes.HotelId) : async Bool {
        switch (hotelRecord.get(hotelId)) {
            case (null) {
                return false;
            };
            case (?result) {
                return true;
            };
        };
    };

    // get number of hotels
    public shared ({ caller }) func getNumberofHotels() : async Result.Result<Nat, Text> {
        try {
            // let isAdmin = await checkIsAdmin(caller);
            // if (isAdmin == false) {
            //     return #err("You are not authorized to access this function");
            // };
            await UtilityFunc.checkAnonymous(caller);

            return #ok(hotelRecord.size());

        } catch e {
            return #err(Error.message(e));
        };
    };

    // get all hotels
    public shared ({ caller }) func getAllHotels(size : Nat, pageNo : Nat) : async Result.Result<[(HotelTypes.HotelId,HotelTypes.HotelInfo)], Text> {
        try {
            // let isAdmin = await checkIsAdmin(caller);
            // if (isAdmin == false) {
            //     return #err("You are not authorized to access this function");
            // };
            await UtilityFunc.checkAnonymous(caller);
            if (pageNo < 1) {
                return #err("Invalid Page Number, Page Number starts from 1");
            };

            let hotelIter = hotelRecord.entries();
            let hotelArr = Iter.toArray(hotelIter);
            var startIndex : Int = 0;
            if (pageNo > 1) {
                startIndex := (pageNo - 1) * 10;
            };
            var endIndex : Int = startIndex + size;
            if (startIndex > hotelArr.size()) {
                return #err("Page Number is out of range");
            };
            if (endIndex > hotelArr.size()) {
                endIndex := hotelArr.size();
            };
            let filteredHotels = Iter.toArray(Array.slice(hotelArr, Int.abs(startIndex), Int.abs(endIndex)));
            
            return #ok(filteredHotels);
        } catch e {
            return #err(Error.message(e));
        };
    };

    // checks if the principal passed is an admin or not
    // public query func checkIsAdmin(caller : Principal) : async Bool {
    //     switch (Array.find<HotelTypes.AdminId>(admin, func(x) : Bool { x == P(caller) })) {
    //         case (null) {
    //             return false;
    //         };
    //         case (?r) {
    //             return true;
    //         };
    //     };
    // };

};
