create table t1('id' INTEGER,'ApplNo' CHARACTER(20),'ApplNoB' CHARACTER(1),'GuaraNo' CHARACTER(5),'InputJson','OutputJson','CreatedUser','CreatedDate','TotalTimespand' INTEGER);
.mode tabs
.import F:/HPM_UAT/DGIS_InputOutput/DGIS_InOutJson_20190125.txt t1
.mode tabs
.output F:/HPM_UAT/DGIS_InputOutput/DGISfile.tsv
select id,ApplNo,ApplNoB,GuaraNo,CreatedUser,CreatedDate,TotalTimespand,
json_extract(t1.InputJson,'$.CollateralData.CaseNo') as                       ApplicationNbr                   ,
json_extract(t1.InputJson,'$.CollateralData.Age') as                          BuildingAge                      ,
json_extract(t1.InputJson,'$.CollateralData.BuildCommercialCnt') as           CountOfCommercialBuilding        ,
json_extract(t1.InputJson,'$.CollateralData.BuildHouseCommercialCnt') as      CountOfMixedBuilding             ,
json_extract(t1.InputJson,'$.CollateralData.BuildHouseCnt') as                CountOfResidentialBuilding       ,
json_extract(t1.InputJson,'$.CollateralData.BuildIndustryCnt') as             CountOfIndustrialBuilding        ,
json_extract(t1.InputJson,'$.CollateralData.BuildPublicCnt') as               CountOfPublicHousing             ,
json_extract(t1.InputJson,'$.CollateralData.BuildingReg') as                  BuildingRegisterCode             ,
json_extract(t1.InputJson,'$.CollateralData.TotalFloorage') as                TotalBuildingAreaWithStall       ,
json_extract(t1.InputJson,'$.CollateralData.ReCalFloorage') as                CaBuildingArea                   ,
json_extract(t1.InputJson,'$.CollateralData.HouseType') as                    BuildingType                     ,
json_extract(t1.InputJson,'$.CollateralData.SurRoundings') as                 SurroundingCode                  ,
json_extract(t1.InputJson,'$.CollateralData.IndoorFloorage') as               MainBuildingArea                 ,
json_extract(t1.InputJson,'$.CollateralData.BuildingMaterial') as             MainMaterialCode                 ,
json_extract(t1.InputJson,'$.CollateralData.FloorOtherCnt') as                CountOfOtherFloor                ,
json_extract(t1.InputJson,'$.CollateralData.FloorFirstCnt') as                CountOfFirstFloor                ,
json_extract(t1.InputJson,'$.CollateralData.FloorTopCnt') as                  CountOfTopFloor                  ,
json_extract(t1.InputJson,'$.CollateralData.FloorOverAllCnt') as              CountOfOverallFloor              ,
json_extract(t1.InputJson,'$.CollateralData.PublicFloorage') as               PublicOwnedArea                  ,
json_extract(t1.InputJson,'$.CollateralData.Fireinsurance') as                RFireInsurance                   ,
json_extract(t1.InputJson,'$.CollateralData.RefUnitPrice') as                 RRefUnitPrice                    ,
json_extract(t1.InputJson,'$.CollateralData.AnnouncementPrice') as            RAnnouncedPrice                  ,
json_extract(t1.InputJson,'$.CollateralData.LandArea') as                     RightMeasure2                    ,
json_extract(t1.InputJson,'$.CollateralData.RoadWidth') as                    RoadWidth                        ,
json_extract(t1.InputJson,'$.CollateralData.TotalPrice') as                   TotalDealPrice                   ,
json_extract(t1.InputJson,'$.CollateralData.ParkingSpaceTotalPrice') as       StallDealPrice                   ,
json_extract(t1.InputJson,'$.Location.FishID') as                             Fishid                           ,
json_extract(t1.InputJson,'$.CollateralData.MainBuilding') as                 NumOfMainBuilding                ,
coalesce(json_extract(t1.InputJson,'$.CollateralData.TotalFloor'),0) as                   TotalFloor                       ,
coalesce(json_extract(t1.InputJson,'$.CollateralData.FloorCode'),0) as                    Floor                            ,
coalesce(json_extract(t1.InputJson,'$.CollateralData.Builder'),'00') as                      ConstructionCo                   ,
coalesce(json_extract(t1.InputJson,'$.CollateralData.ProjectName'),'00') as                  CommunityName                    ,
json_extract(t1.InputJson,'$.Location.X') as                 Location_X                ,
json_extract(t1.InputJson,'$.Location.Y') as                 Location_Y,
json_extract(t1.InputJson,'$.Location.CompareLV') as                 CompareLV
from t1;
.mode tabs
.output F:/HPM_UAT/DGIS_InputOutput/OutputJson.tsv
select OutputJson from t1;
