dfx canister call Hotel createHotel '(record {hotelDes="hotel hola"; hotelAvailableFrom="14-12-2001"; hotelAvailableTill="14-12-2002"; createdAt="14-12-2001"; hotelId="1234"; hotelImage="xts"; hotelTitle="Hola"; hotelLocation="afdg"}, record {roomPrice=345; roomType="single bed"})'

dfx canister call Hotel getHotel '("sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae#4def40ad-142e-40d2-bb8a-f830f479f9ac")'
dfx canister call Hotel getRoom '("sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae#841d5f5a-e5a1-472e-8371-43b66cc39d86")'


dfx canister call Hotel getHotelRegisterFrequencyData '("2024")'
dfx canister call Hotel getHotelRegisterFrequencyData '("2023")'

dfx canister call Hotel updateHotel '(record {hotelDes="H desc"; hotelAvailableFrom="14-14-14"; hotelAvailableTill="15-15-15"; createdAt="10:30"; hotelId="sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae#ffc4dfc3-9a33-4da5-aa62-f5070adcb0c0"; hotelImage="img"; hotelTitle="afs"; hotelLocation="122"}, record {roomPrice=12323; roomType="12"})'

dfx canister call Hotel deleteHotel '("sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae#4def40ad-142e-40d2-bb8a-f830f479f9ac")'
dfx canister call Hotel getHotel '("sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae#4def40ad-142e-40d2-bb8a-f830f479f9ac")'

dfx canister call Hotel whoami

dfx canister call Hotel checkHotelExist '("sfwko-hd7us-gen5t-ssuci-vfjwf-afepb-a7p4y-guh5l-s5n2e-zuxvt-dae#71c898a9-e96a-4872-b290-814b82295731")'

dfx canister call Hotel getNumberofHotels
dfx canister call Hotel getAllHotels '(10,1)'