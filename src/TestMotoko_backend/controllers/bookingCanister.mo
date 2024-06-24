import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Error "mo:base/Error";
import BookingTypes "../types/bookingTypes";
import UtilityFunc "../utils/utilityFunc";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Icrc "../utils/icrc";
import Char "mo:base/Char";
import Month "../utils/month";

shared({caller=owner}) actor class Booking(){
    var bookingRecord = TrieMap.TrieMap<Text,BookingTypes.BookingInfo>(Text.equal, Text.hash);
    var hotelBookingRecord = TrieMap.TrieMap<Text,[BookingTypes.BookingInfo]>(Text.equal,Text.hash);
    var userBookingRecord = TrieMap.TrieMap<Principal,[BookingTypes.BookingInfo]>(Principal.equal,Principal.hash);
    var bookingFreq = TrieMap.TrieMap<Text,BookingTypes.AnnualData>(Text.equal,Text.hash);
    var solanaPayments:Nat=0;

    let icpLedger = "ryjl3-tyaaa-aaaaa-aaaba-cai";
    let ckbtcLedger = "mxzaz-hqaaa-aaaar-qaada-cai";
    let ckethLedger = "ss2fx-dyaaa-aaaar-qacoq-cai";

    // create a new booking
    public shared({caller}) func createBooking(paymentType:BookingTypes.PaymentType,booking:BookingTypes.BookingInput,amount:Nat):async Result.Result<Text,Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);
            let time=DateTime.DateTime(Time.now()).toText();
            let uuid = await UtilityFunc.getUuid();
            let newBookingId = booking.hotelId # "#" # uuid; 
            var payId = "";
            let hotelOwnerId = getHotelOwnerIdFromHotelId(booking.hotelId);
            switch(paymentType){
                case(#icp(val)){
                    let response : Icrc.Result_2 = await icrc2_transferFrom(icpLedger, caller, Principal.fromText(hotelOwnerId), amount);
                    switch(response){
                        case(#Ok(value)){
                            payId:="icp "# Nat.toText(value);
                        };
                        case(#Err(err)){
                            return #err("Error occured  while ICP payment !");
                        }
                    };
                };
                case(#ckBTC(val)){
                    let response : Icrc.Result_2 = await icrc2_transferFrom(ckbtcLedger, caller, Principal.fromText(hotelOwnerId), amount);
                    switch(response){
                        case(#Ok(value)){
                            payId:="ckbtc "# Nat.toText(value);
                        };
                        case(#Err(err)){
                            return #err("Error occured  while ckBTC payment !");
                        }
                    };
                };
                case(#ckETH(val)){
                    let response : Icrc.Result_2 = await icrc2_transferFrom(ckethLedger, caller, Principal.fromText(hotelOwnerId), amount);
                    switch(response){
                        case(#Ok(value)){
                            payId:="cketh "# Nat.toText(value);
                        };
                        case(#Err(err)){
                            return #err("Error occured  while ckETH payment !");
                        }
                    };
                };
                case(#sol){
                    payId:="sol "# Nat.toText(solanaPayments);
                    solanaPayments:= solanaPayments+1;
                    return #err("not complete");
                };

            };
            let newBooking:BookingTypes.BookingInfo={
                hotelId=booking.hotelId;
                userId=Principal.toText(caller);
                checkInDate=booking.checkInDate;
                checkOutDate=booking.checkOutDate;
                bookingDuration=booking.bookingDuration;
                paymentStatus=true;
                cancelStatus=false;
                paymentId=payId;
                bookingDate=time;
                bookingId=newBookingId;
                refundStatus=false;
            };
            bookingRecord.put(newBookingId,newBooking);                    
            switch(hotelBookingRecord.get(booking.hotelId)) {
                case(null) { 
                    var hotelBuff:Buffer.Buffer<BookingTypes.BookingInfo> = Buffer.fromArray([]);
                    hotelBuff.add(newBooking);
                    hotelBookingRecord.put(booking.hotelId,Buffer.toArray(hotelBuff));
                };
                case(?hotelBookingPrevArr) { 
                    var hotelBuff:Buffer.Buffer<BookingTypes.BookingInfo> =Buffer.fromArray(hotelBookingPrevArr);
                    hotelBuff.add(newBooking);
                    ignore hotelBookingRecord.replace(booking.hotelId,Buffer.toArray(hotelBuff));
                };
            };
            switch(userBookingRecord.get(caller)){
                case(null){
                    var userBuff:Buffer.Buffer<BookingTypes.BookingInfo> = Buffer.fromArray([]);
                    userBuff.add(newBooking);
                    userBookingRecord.put(caller,Buffer.toArray(userBuff));
                };
                case(?userBookingArr){
                    var userBuff:Buffer.Buffer<BookingTypes.BookingInfo> = Buffer.fromArray(userBookingArr);
                    userBuff.add(newBooking);
                    ignore userBookingRecord.replace(caller,Buffer.toArray(userBuff));
                };
            };
            var counter = 0;
            var year = "";
            var month = "";

            for (i in Text.toIter(time)) {
                if (counter <= 3) {
                    year := year # Char.toText(i);
                };
                if (counter > 5 and counter <= 6) {
                    month := month # Char.toText(i);
                };
                counter += 1;
            };
            switch (bookingFreq.get(year)) {
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
                    bookingFreq.put(year, monthData);

                };
                case (?result) {
                    let updatedMonthData = Month.updateMonthData(month, result);
                    ignore bookingFreq.replace(year, updatedMonthData);
                };
            };
            return #ok("Your booking is updated !");
        }catch e{
            return #err(Error.message(e));
        }
    };

    // returns all hotel revervations
    public shared({caller}) func getAllHotelBookings(hotelId:Text):async Result.Result<[BookingTypes.BookingInfo],Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);
            switch(hotelBookingRecord.get(hotelId)){
                case(null){
                    return #ok([])
                };
                case(?bookings){
                    return #ok(bookings);
                }
            }
        }catch e {
            #err(Error.message(e));
        }
    };

    // returns all user specofic bookings
    public shared({caller}) func getAllUserBookings():async Result.Result<[BookingTypes.BookingInfo],Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);
            switch(userBookingRecord.get(caller)){
                case(null){
                    return #ok([]);
                };
                case(?bookings){
                    return #ok(bookings)
                }
            }
        }catch e{
            return #err(Error.message(e));
        }
    };

    // returns details of a booking
    public shared({caller}) func getBookingDetails(bookingId:Text):async Result.Result<BookingTypes.BookingInfo,Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);
            switch(bookingRecord.get(bookingId)){
                case(null){
                    #err("no booking with this id found !");
                };
                case(?booking){
                    return #ok(booking);
                }
            }
        }catch e{
            return #err(Error.message(e));
        }
    };

    // returns frequency of hotel bookings happening each month, year wise
    public shared({caller}) func getBookingFrequency(year:Text):async Result.Result<BookingTypes.AnnualData,Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);
            switch(bookingFreq.get(year)){
                case(null){
                    return #err("No data for this year");
                };
                case(?data){
                    return #ok(data);
                }
            }
        }catch e{   
            return #err(Error.message(e));
        }
    };

    // transfer function
    func icrc2_transferFrom(ledgerId : Text, transferfrom : Principal, transferto : Principal, amount : Nat) : async Icrc.Result_2 {

        let ledger = actor (ledgerId) : Icrc.Token;
        await ledger.icrc2_transfer_from({
            spender_subaccount = null;
            from = {owner = transferfrom; subaccount = null};
            to = {owner = transferto; subaccount = null};
            amount;
            fee = null;
            memo = null;
            created_at_time = null;
        });

    };

    //returns host id for a hotelId
    func getHotelOwnerIdFromHotelId(hotelId : Text) : Text {
        let array = Iter.toArray(Text.split(hotelId, #char '#'));
        array[0];
    };

}