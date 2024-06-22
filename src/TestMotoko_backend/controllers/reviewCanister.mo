import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Float "mo:base/Float";
import Int "mo:base/Int";
import DateTime "mo:datetime/DateTime";
import ReviewTypes "../types/reviewTypes";
import UtilityFunc "../utils/utilityFunc";

shared({caller=owner}) actor class Review(){

    var hotelReviewRecords = TrieMap.TrieMap<Text,[Text]>(Text.equal, Text.hash);
    var reviewRecords= TrieMap.TrieMap<Text,ReviewTypes.Review>(Text.equal,Text.hash);

    // creates review on a hotel by a certain user
    public shared({caller}) func createReview(hotelId:Text,review:ReviewTypes.ReviewInput):async Result.Result<Text,Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);
            let time=DateTime.DateTime(Time.now()).toText();
            let reviewId=hotelId # Principal.toText(caller);
            let newReview:ReviewTypes.Review={
                reviewId=reviewId;
                userId=Principal.toText(caller);
                hotelId=hotelId;
                rating=review.rating;
                title=review.title;
                des=review.des;
                createdAt=time;
            };
            switch(hotelReviewRecords.get(hotelId)){
                case(null){
                    reviewRecords.put(reviewId,newReview);
                    var newReviewList:Buffer.Buffer<Text> = Buffer.fromArray([]);
                    newReviewList.add(reviewId);
                    hotelReviewRecords.put(hotelId,Buffer.toArray(newReviewList));
                    return #ok("Your review is added, first review on this hotel !")
                };
                case(?hotelReviewList){
                    switch(reviewRecords.get(reviewId)){
                        case(null){
                            reviewRecords.put(reviewId,newReview);
                            var newReviewList:Buffer.Buffer<Text> = Buffer.fromArray(hotelReviewList);
                            newReviewList.add(reviewId);
                            hotelReviewRecords.put(hotelId,Buffer.toArray(newReviewList));
                            return #ok("Your review is added !");
                        };
                        case(?existingReview){
                            ignore reviewRecords.replace(reviewId,newReview);
                            return #ok("Your review is updated !");
                        };
                    }
                }
            };
            return #err("not complete");

        }catch e{
            return #err(Error.message(e));
        }
    };

    // returns reviews on a hotel
    public shared ({caller}) func getAllReviewsOnHotel(hotelId:Text):async Result.Result<[ReviewTypes.Review],Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);
            switch(hotelReviewRecords.get(hotelId)){
                case(null){
                    return #ok([]);
                };
                case(?reviewIdList){
                    var reviewBuff:Buffer.Buffer<ReviewTypes.Review> = Buffer.fromArray([]);
                    for(i in reviewIdList.keys()){
                        switch(reviewRecords.get(reviewIdList[i])){
                            case(null){
                                // continue
                            };
                            case(?rev){
                                reviewBuff.add(rev);
                            }
                        }
                    };
                    return #ok(Buffer.toArray(reviewBuff));
                }
            }
        }catch e{
            return #err(Error.message(e));
        }   
    };

    // returns the rating of a hotel based on reviews placed on it
    public shared({caller}) func getHotelRating(hotelId:Text):async Result.Result<Nat,Text>{
        try{
            await UtilityFunc.checkAnonymous(caller);

            switch(hotelReviewRecords.get(hotelId)){
                case(null){
                    return #ok(5);
                };
                case(?reviewIdList){
                    let noOfReviews=reviewIdList.size();
                    var sumOfRatings:Nat=0;
                    for(i in reviewIdList.keys()){
                        switch(reviewRecords.get(reviewIdList[i])){
                            case(null){};
                            case(?rev){
                                sumOfRatings:=sumOfRatings+Int.abs(Float.toInt(rev.rating));
                            };
                        };
                    };
                    let rating=sumOfRatings/noOfReviews;
                    return #ok(rating);
                }
            }
        }catch e{
            return #err(Error.message(e));
        }
    };

    // returns the principal of a user
    public shared query ({caller}) func whoami():async Text{
        return Principal.toText(caller);
    }
}