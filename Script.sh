dfx canister call User registerUser '(record {firstName="Atharva";lastName="Bhatnagar";dob="2001-01-01";userEmail="atv@gmail.com"})'
# dfx canister call User getuserDetails
# dfx canister call User updateUserDetails '(record {dob = "2001-02-02";userRole = "host";userEmail = "atv@gmail.com";userGovID = "123456";userID = principal "sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae";createdAt = "2024-06-21T07:51:21.432775484Z";agreementStatus = false;govIDLink = "link.com";isHost = true;userImage = "img.png";isVerified = true;lastName = "Bhatnagar";firstName = "Atharva"})'
# dfx canister call User getuserDetails
# echo "\n Now Calling Delete User\n"
# dfx canister call User deleteUser 
# dfx canister call User getUserByPrincipal '(principal "sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae")'
dfx canister call User getAnnualRegisterByYear '("2024")'