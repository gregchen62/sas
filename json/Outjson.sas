options compress=yes;
%let yyyymmdd=20190125;

%let Local_file_Path=F:\HPM_UAT\DGIS_InputOutput;
%let Local_file_Path2=F:/HPM_UAT/DGIS_InputOutput;
*20190104 add;
/*x "del /Q /S &Local_file_Path.\DGIS_InOutJson";*/
x "c:\progra~2\7-zip\7z x &Local_file_Path.\DGIS_InOutJson_&yyyymmdd..zip -y -o&Local_file_Path.";
/*x "rename &Local_file_Path.\DGIS_InOutJson_&yyyymmdd. DGIS_InOutJson_&yyyymmdd..txt"; */
/*data _null_;
infile "&Local_file_Path.\DGIS_InOutJson" lrecl=%sysevalf(32767*200);
file "&Local_file_Path.\DGIS_INOPTPUT_&yyyymmdd..txt" encoding='utf-8' lrecl=%sysevalf(32767*200);
input;
put _infile_;
run;*/

*END 20190104 add;

x "del /Q /S &Local_file_Path.\json\*.json";
x "del /Q /S &Local_file_Path.\TEST_DB.DB";
x "del /Q /S &Local_file_Path.\SQLITE_DB.DB";
x "del /Q /S &Local_file_Path.\*.tsv";
X "del /Q /S &Local_file_Path.\json\*.json";
X "del /Q /S &Local_file_Path.\json2\*.json";
X "del /Q /S &Local_file_Path.\csv\*.*";
X "del /Q /S &Local_file_Path.\csv2\*.*";

x "del /Q /S &Local_file_Path.\DGIS_input.sas7bdat";
x "del /Q /S &Local_file_Path.\outputjson_perf.sas7bdat";
x "del /Q /S &Local_file_Path.\outputjson_result.sas7bdat";
x "del /Q /S &Local_file_Path.\DGIS_INPUTOUTPUT_&yyyymmdd..sas7bdat";

x "del /Q /S &Local_file_Path.\DGISfile.tsv";
x "del /Q /S &Local_file_Path.\OutputJson.tsv";

libname dgis "&Local_file_Path.";
/*
filename foodir pipe "dir/a:-d/-c/t:w/4 &Local_file_Path.\*.txt ";
 
data work.local_list;
      infile foodir firstobs=6;
      length filename $200 local_size 8 local_file_dt 8 ;
      input;
      if prxmatch('/^\d{1,}/',_infile_) > 0;          
      yymmdd = input(scan(_infile_,1,' '),anydtdte10.);
      time  = input(scan(_infile_,3,' '),hhmmss.);
      if scan(_infile_,2,' ') = '¤U¤È' then time = time + hms(12,0,0);
      local_file_dt = input(put(yymmdd, yymmdd10.)||' '||put(time,time8.),anydtdtm.);
      local_size = input(scan(_infile_,-2,' '), best16.);
      filename = scan(_infile_,-1,' ');
      format local_file_dt e8601dt22.0 yymmdd yymmdd10.;
      keep filename local_size local_file_dt;
run; 

proc sql noprint;
      select filename into: DGISfile
      from work.local_list(obs=1)
;quit;
*/
%let DGISfile=DGIS_InOutJson_&yyyymmdd..txt;
%put &DGISfile.;

*sqlite;
data _null_;
    file "&Local_file_Path.\DGIS.sql";
    a1="create table t1('id' INTEGER,'ApplNo' CHARACTER(20),'ApplNoB' CHARACTER(1),'GuaraNo' CHARACTER(5),'InputJson','OutputJson','CreatedUser','CreatedDate','TotalTimespand' INTEGER);";
    a2=".mode tabs";
    a3=".import &Local_file_Path2./%trim(&DGISfile.) t1";
    a4=".mode tabs";
    a5=".output &Local_file_Path2./DGISfile.tsv";
    a6_01="select id,ApplNo,ApplNoB,GuaraNo,CreatedUser,CreatedDate,TotalTimespand,";
    a6_02="json_extract(t1.InputJson,'$.CollateralData.CaseNo') as                       ApplicationNbr                   ,";
    a6_03="json_extract(t1.InputJson,'$.CollateralData.Age') as                          BuildingAge                      ,";
    a6_04="json_extract(t1.InputJson,'$.CollateralData.BuildCommercialCnt') as           CountOfCommercialBuilding        ,";
    a6_05="json_extract(t1.InputJson,'$.CollateralData.BuildHouseCommercialCnt') as      CountOfMixedBuilding             ,";
    a6_06="json_extract(t1.InputJson,'$.CollateralData.BuildHouseCnt') as                CountOfResidentialBuilding       ,";
    a6_07="json_extract(t1.InputJson,'$.CollateralData.BuildIndustryCnt') as             CountOfIndustrialBuilding        ,";
    a6_08="json_extract(t1.InputJson,'$.CollateralData.BuildPublicCnt') as               CountOfPublicHousing             ,";
    a6_09="json_extract(t1.InputJson,'$.CollateralData.BuildingReg') as                  BuildingRegisterCode             ,";
    a6_10="json_extract(t1.InputJson,'$.CollateralData.TotalFloorage') as                TotalBuildingAreaWithStall       ,";
    a6_11="json_extract(t1.InputJson,'$.CollateralData.ReCalFloorage') as                CaBuildingArea                   ,";
    a6_12="json_extract(t1.InputJson,'$.CollateralData.HouseType') as                    BuildingType                     ,";
    a6_13="json_extract(t1.InputJson,'$.CollateralData.SurRoundings') as                 SurroundingCode                  ,";
    a6_14="json_extract(t1.InputJson,'$.CollateralData.IndoorFloorage') as               MainBuildingArea                 ,";
    a6_15="json_extract(t1.InputJson,'$.CollateralData.BuildingMaterial') as             MainMaterialCode                 ,";
    a6_16="json_extract(t1.InputJson,'$.CollateralData.FloorOtherCnt') as                CountOfOtherFloor                ,";
    a6_17="json_extract(t1.InputJson,'$.CollateralData.FloorFirstCnt') as                CountOfFirstFloor                ,";
    a6_18="json_extract(t1.InputJson,'$.CollateralData.FloorTopCnt') as                  CountOfTopFloor                  ,";
    a6_19="json_extract(t1.InputJson,'$.CollateralData.FloorOverAllCnt') as              CountOfOverallFloor              ,";
    a6_20="json_extract(t1.InputJson,'$.CollateralData.PublicFloorage') as               PublicOwnedArea                  ,";
    a6_21="json_extract(t1.InputJson,'$.CollateralData.Fireinsurance') as                RFireInsurance                   ,";
    a6_22="json_extract(t1.InputJson,'$.CollateralData.RefUnitPrice') as                 RRefUnitPrice                    ,";
    a6_23="json_extract(t1.InputJson,'$.CollateralData.AnnouncementPrice') as            RAnnouncedPrice                  ,";
    a6_24="json_extract(t1.InputJson,'$.CollateralData.LandArea') as                     RightMeasure2                    ,";
    a6_25="json_extract(t1.InputJson,'$.CollateralData.RoadWidth') as                    RoadWidth                        ,";
    a6_26="json_extract(t1.InputJson,'$.CollateralData.TotalPrice') as                   TotalDealPrice                   ,";
    a6_27="json_extract(t1.InputJson,'$.CollateralData.ParkingSpaceTotalPrice') as       StallDealPrice                   ,";
    a6_32="json_extract(t1.InputJson,'$.Location.FishID') as                             Fishid                           ,";
    a6_33="json_extract(t1.InputJson,'$.CollateralData.MainBuilding') as                 NumOfMainBuilding                ,";
    a6_30="coalesce(json_extract(t1.InputJson,'$.CollateralData.TotalFloor'),0) as                   TotalFloor                       ,";
    a6_31="coalesce(json_extract(t1.InputJson,'$.CollateralData.FloorCode'),0) as                    Floor                            ,";
    a6_28="coalesce(json_extract(t1.InputJson,'$.CollateralData.Builder'),'00') as                      ConstructionCo                   ,";
    a6_29="coalesce(json_extract(t1.InputJson,'$.CollateralData.ProjectName'),'00') as                  CommunityName                    ,";
    a6_35="json_extract(t1.InputJson,'$.Location.X') as                 Location_X                ,";
    a6_36="json_extract(t1.InputJson,'$.Location.Y') as                 Location_Y,";
    a6_37="json_extract(t1.InputJson,'$.Location.CompareLV') as                 CompareLV";
    a6_34="from t1;";
    a7=".mode tabs";
    a8=".output &Local_file_Path2./OutputJson.tsv";
    a9="select OutputJson from t1;";
    put a1;
    put    a2;
    put    a3;
    put    a4;
    put    a5;
    put a6_01;
    put a6_02;
    put a6_03;
    put a6_04;
    put a6_05;
    put a6_06;
    put a6_07;
    put a6_08;
    put a6_09;
    put a6_10;
    put a6_11;
    put a6_12;
    put a6_13;
    put a6_14;
    put a6_15;
    put a6_16;
    put a6_17;
    put a6_18;
    put a6_19;
    put a6_20;
    put a6_21;
    put a6_22;
    put a6_23;
    put a6_24;
    put a6_25;
    put a6_26;
    put a6_27;
    put a6_32;
    put a6_33;
    put a6_30;
    put a6_31;
    put a6_28;
    put a6_29;
    put a6_35;
    put a6_36;
    put a6_37;
    put a6_34;
    put    a7;
    put    a8;
    put    a9;
run;

/*filename PIP pipe "&Local_file_Path.\sqlit3json &Local_file_Path.\TEST_DB.DB < &Local_file_Path.\DGIS.sql";*/
filename PIP pipe "&Local_file_Path.\sqlit3json &Local_file_Path.\SQLITE_DB.DB < &Local_file_Path.\DGIS.sql";
data aa;
infile PIP;
length file $255.;
input file;
run;


filename DGISfile "&Local_file_Path.\DGISfile.tsv";
data dgis.DGIS_input;
/*infile DGISfile dlm='09'x encoding="big5" MISSOVER ;*/
infile DGISfile dlm='09'x encoding="utf-8" MISSOVER DSD;
format no 10. id 5. ApplNo $15. ApplNoB $1. CollateralNbr $5. CreatedUser $8. CreatedDate $20. TotalTimespand 10.
ApplicationNbr $17.00 BuildingAge BEST2. CountOfCommercialBuilding BEST5. CountOfMixedBuilding BEST5. CountOfResidentialBuilding BEST5.
CountOfIndustrialBuilding BEST5. CountOfPublicHousing BEST5. BuildingRegisterCode $CHAR2. TotalBuildingAreaWithStall BEST18.
CaBuildingArea BEST5. BuildingType $CHAR2. SurroundingCode $CHAR2. MainBuildingArea BEST5. MainMaterialCode $CHAR2. 
CountOfOtherFloor BEST5. CountOfFirstFloor BEST5. CountOfTopFloor BEST5. CountOfOverallFloor BEST5.
PublicOwnedArea BEST18. RFireInsurance BEST18. RRefUnitPrice BEST7. RAnnouncedPrice BEST30. RightMeasure2 BEST5.
RoadWidth BEST12. TotalDealPrice BEST5. StallDealPrice BEST5. 
Fishid BEST6. NumOfMainBuilding BEST2.
TotalFloor BEST5. Floor BEST5. 
ConstructionCo $CHAR30. CommunityName $CHAR30.
Location_X $CHAR30. Location_Y $CHAR30. CompareLV $CHAR30.
;

input id ApplNo $ ApplNoB $ CollateralNbr $ CreatedUser $ CreatedDate $ TotalTimespand ApplicationNbr $ BuildingAge CountOfCommercialBuilding CountOfMixedBuilding CountOfResidentialBuilding
CountOfIndustrialBuilding CountOfPublicHousing BuildingRegisterCode $ TotalBuildingAreaWithStall CaBuildingArea BuildingType $ SurroundingCode $ MainBuildingArea 
MainMaterialCode $ CountOfOtherFloor CountOfFirstFloor CountOfTopFloor CountOfOverallFloor PublicOwnedArea RFireInsurance RRefUnitPrice RAnnouncedPrice RightMeasure2
RoadWidth TotalDealPrice StallDealPrice 
Fishid NumOfMainBuilding
TotalFloor Floor 
ConstructionCo $ CommunityName $ 
Location_X $ Location_Y $ CompareLV $
;
no=_n_;
run;

proc sql noprint;
select count(*) into :N from dgis.DGIS_input
;quit;
%put &n.;


filename Json "&Local_file_Path.\OutputJson.tsv";
%macro oo();
%do i=1 %to &n.;
    data _null_;
/*    infile Json encoding="big5" lrecl=%sysevalf(32767*200) firstobs=&i. obs=&i.;*/
    infile Json encoding="utf-8" lrecl=%sysevalf(32767*200) firstobs=&i. obs=&i.;
    length _header $24.;
    input _header;
    file "&Local_file_Path.\json\&i..json" recfm=n;
    if _header='{"PerformanceStatistic":' then do;
        put  _infile_;
    end;
    run;

    data _null_;
/*    infile Json encoding="big5" lrecl=%sysevalf(32767*200) firstobs=&i. obs=&i.;*/
    infile Json encoding="utf-8" lrecl=%sysevalf(32767*200) firstobs=&i. obs=&i.;
    length _header $24.;
    input _header;
    file "&Local_file_Path.\json2\&i..json" recfm=n;
    if _header^='{"PerformanceStatistic":' then do;
        put  _infile_;
    end;
    run;
%end;
%mend;
%oo();


*****END of Replace*******;
%macro dd(json);
    X "del /Q /S &Local_file_Path.\json\&json.";
%mend;

%macro aa(json);
    systask command "copy &Local_file_Path.\json\&json. &Local_file_Path.\csv\" wait status=cpy;
    systask command "F:\HPM_UAT\JSON_to_CSV\R-3.5.1\bin\x64\Rscript.exe &Local_file_Path.\HPM_JSON_to_CSV_Perf.R" wait status=Rcde;
    systask command "del /Q /S &Local_file_Path.\csv\&json." wait status=del;
%mend;

filename foodir pipe "dir/a:-d/-c/t:w/4 &Local_file_Path.\json\*.json";
data work.json_list;
      infile foodir firstobs=6;
      length filename $200 local_size 8 local_file_dt 8 ;
      input;
      if prxmatch('/^\d{1,}/',_infile_) > 0;          
      yymmdd = input(scan(_infile_,1,' '),anydtdte10.);
      time  = input(scan(_infile_,3,' '),hhmmss.);
      if scan(_infile_,2,' ') = '¤U¤È' then time = time + hms(12,0,0);
      local_file_dt = input(put(yymmdd, yymmdd10.)||' '||put(time,time8.),anydtdtm.);
      local_size = input(scan(_infile_,-2,' '), best16.);
      filename = scan(_infile_,-1,' ');
      format local_file_dt e8601dt22.0 yymmdd yymmdd10.;
      keep filename local_size local_file_dt;
if local_size=0 then do;
    call execute('%dd('||filename||')');
end;
else do;
    call execute('%aa('||filename||')');
end;
run; 
 systask command "F:\HPM_UAT\JSON_to_CSV\R-3.5.1\bin\x64\Rscript.exe &Local_file_Path.\Perf_TXT_CSV_SET.R" wait status=Rcde2;

*****************************;
*Result REPLACE json2 '' to "";
*Result REPLACE json2 null to "NULL";
filename dirlist PIPE "powershell -Command -< &Local_file_Path.\DGIS_REST.ps1";
data dirlist;
  infile dirlist missover pad;
  input filename $255.;
run;
*****END of Replace*******;

%macro dd2(json);
    X "del /Q /S &Local_file_Path.\json2\&json.";
%mend;

%macro aa2(json);
systask command "copy &Local_file_Path.\json2\&json. &Local_file_Path.\csv2\" wait status=cpy2;
systask command "F:\HPM_UAT\JSON_to_CSV\R-3.5.1\bin\x64\Rscript.exe &Local_file_Path.\HPM_JSON_to_CSV_Result.R" wait status=Rcde2;
systask command "del /Q /S &Local_file_Path.\csv2\&json." wait status=del2;
%mend;

filename foodir pipe "dir/a:-d/-c/t:w/4 &Local_file_Path.\json2\*.json";
data work.json_list;
      infile foodir firstobs=6;
      length filename $200 local_size 8 local_file_dt 8 ;
      input;
      if prxmatch('/^\d{1,}/',_infile_) > 0;          
      yymmdd = input(scan(_infile_,1,' '),anydtdte10.);
      time  = input(scan(_infile_,3,' '),hhmmss.);
      if scan(_infile_,2,' ') = '¤U¤È' then time = time + hms(12,0,0);
      local_file_dt = input(put(yymmdd, yymmdd10.)||' '||put(time,time8.),anydtdtm.);
      local_size = input(scan(_infile_,-2,' '), best16.);
      filename = scan(_infile_,-1,' ');
      format local_file_dt e8601dt22.0 yymmdd yymmdd10.;
      keep filename local_size local_file_dt;
if local_size=0 then do;
    call execute('%dd2('||filename||')');
end;
else do;
    call execute('%aa2('||filename||')');
end;
run; 
 systask command "F:\HPM_UAT\JSON_to_CSV\R-3.5.1\bin\x64\Rscript.exe &Local_file_Path.\Result_TXT_CSV_SET.R" wait status=Rcde3;


***************************;
%macro fmt();
no                                      5.
ApplicationNbr_outjson                  $20.
CollateralNbr_outjson                   $20.
ZipCode                                 $20.
SectorNum                               $20.
LocationCode                            $20.
PublicRatio                             $20.
RStallAppraisePrice                     $20.
StallArea                               $20.
BuildingNameFlg                         $20.
TargetNewFlg                            $20.
CountOfNegativeCode                     $20.
AvgPriceL6m                             $20.
Exclusion                               $20.
TotalBuildingArea                       $20.
StallCountsP                            $20.
StallCountsM                            $20.
ActuralHousePriceCounts                 $20.
ActuralHousePriceMean                   $20.
ActuralHousePriceP50                    $20.
ActuralHousePriceP5                     $20.
ActuralHousePriceP95                    $20.
AgentHousePriceCounts                   $20.
AgentHousePriceMean                     $20.
AgentHousePriceP50                      $20.
AgentHousePriceP5                       $20.
AgentHousePriceP95                      $20.
CommunityHousePriceCounts               $20.
CommunityHousePriceMean                 $20.
CommunityHousePriceP50                  $20.
CommunityHousePriceP5                   $20.
CommunityHousePriceP95                  $20.
ActuralPlaneStallPriceCounts            $20.
ActuralPlaneStallPriceMean              $20.
ActuralPlaneStallPriceP50               $20.
ActuralPlaneStallPriceP5                $20.
ActuralPlaneStallPriceP95               $20.
ActuralMechanicalStallMPriceCoun        $20.
ActuralMechanicalStallMPriceMean        $20.
ActuralMechanicalStallMPriceP50         $20.
ActuralMechanicalStallMPriceP5          $20.
ActuralMechanicalStallMPriceP95         $20.
CommunityPlaneStallPriceCounts          $20.
CommunityPlaneStallPriceMean            $20.
CommunityPlaneStallPriceP50             $20.
CommunityPlaneStallPriceP5              $20.
CommunityPlaneStallPriceP95             $20.
CommunityMechanicalStallPriceCou        $20.
CommunityMechanicalStallPriceMea        $20.
CommunityMechanicalStallPriceP50        $20.
CommunityMechanicalStallPriceP5         $20.
CommunityMechanicalStallPriceP95        $20.
LivableIndicatorDistance1               $20.
LivableIndicatorDistance2               $20.
LivableIndicatorDistance3               $20.
LivableIndicatorDistance4               $20.
LivableIndicatorDistance5               $20.
LivableIndicatorDistance6               $20.
LivableIndicatorDistanceSpare1          $20.
LivableIndicatorDistanceSpare2          $20.
LivableIndicatorDistanceSpare3          $20.
LivableIndicatorDistanceSpare4          $20.
LivableIndicatorDistanceSpare5          $20.
LivableIndicatorDistanceSpare6          $20.
LivableIndicatorDistanceSpare7          $20.
LivableIndicatorDistanceSpare8          $20.
LivableIndicatorDistanceSpare9          $20.
ContractNote                            $20.
ContractUnitPrice                       $20.
ContractTownhouseUnitPrice              $20.
ContractTownhouseLandUnitPrice          $20.
ContractTotalPrice                      $20.
AvgPlaneStallEstUnitPrice               $20.
AvgMechanicalStallEstUnitPrice          $20.
Seg                                     $20.
T1ModelName                             $20.
T1_OriginalScore                        $20.
T1_TransformedScore                     $20.
T2_OriginalScore                        $20.
T2_TransformedScore                     $20.
FinalScore                              $20.
FinalTransformedScore                   $20.
HpmUnitPrice                            $20.
HpmTotalPrice                           $20.
HpmModelFlag                            $20.
StallFlag                               $20.
PolicyHousePrice                        $20.
PolicyStallPrice                        $20.
PolicyTotalPrice                        $20.
PolicyTotalPriceWithStall               $20.
FinalHousePrice                         $20.
FinalStallPrice                         $20.
FinalTotalPrice                         $20.
FinalTotalPriceWithStall                $20.
HierachyFlag                            $20.
%mend;
%macro inp();
no                                      
ApplicationNbr_outjson                  $
CollateralNbr_outjson                   $
ZipCode                                 $
SectorNum                               $
LocationCode                            $
PublicRatio                             $
RStallAppraisePrice                     $
StallArea                               $
BuildingNameFlg                         $
TargetNewFlg                            $
CountOfNegativeCode                     $
AvgPriceL6m                             $
Exclusion                               $
TotalBuildingArea                       $
StallCountsP                            $
StallCountsM                            $
ActuralHousePriceCounts                 $
ActuralHousePriceMean                   $
ActuralHousePriceP50                    $
ActuralHousePriceP5                     $
ActuralHousePriceP95                    $
AgentHousePriceCounts                   $
AgentHousePriceMean                     $
AgentHousePriceP50                      $
AgentHousePriceP5                       $
AgentHousePriceP95                      $
CommunityHousePriceCounts               $
CommunityHousePriceMean                 $
CommunityHousePriceP50                  $
CommunityHousePriceP5                   $
CommunityHousePriceP95                  $
ActuralPlaneStallPriceCounts            $
ActuralPlaneStallPriceMean              $
ActuralPlaneStallPriceP50               $
ActuralPlaneStallPriceP5                $
ActuralPlaneStallPriceP95               $
ActuralMechanicalStallMPriceCoun        $
ActuralMechanicalStallMPriceMean        $
ActuralMechanicalStallMPriceP50         $
ActuralMechanicalStallMPriceP5          $
ActuralMechanicalStallMPriceP95         $
CommunityPlaneStallPriceCounts          $
CommunityPlaneStallPriceMean            $
CommunityPlaneStallPriceP50             $
CommunityPlaneStallPriceP5              $
CommunityPlaneStallPriceP95             $
CommunityMechanicalStallPriceCou        $
CommunityMechanicalStallPriceMea        $
CommunityMechanicalStallPriceP50        $
CommunityMechanicalStallPriceP5         $
CommunityMechanicalStallPriceP95        $
LivableIndicatorDistance1               $
LivableIndicatorDistance2               $
LivableIndicatorDistance3               $
LivableIndicatorDistance4               $
LivableIndicatorDistance5               $
LivableIndicatorDistance6               $
LivableIndicatorDistanceSpare1          $
LivableIndicatorDistanceSpare2          $
LivableIndicatorDistanceSpare3          $
LivableIndicatorDistanceSpare4          $
LivableIndicatorDistanceSpare5          $
LivableIndicatorDistanceSpare6          $
LivableIndicatorDistanceSpare7          $
LivableIndicatorDistanceSpare8          $
LivableIndicatorDistanceSpare9          $
ContractNote                            $
ContractUnitPrice                       $
ContractTownhouseUnitPrice              $
ContractTownhouseLandUnitPrice          $
ContractTotalPrice                      $
AvgPlaneStallEstUnitPrice               $
AvgMechanicalStallEstUnitPrice          $
Seg                                     $
T1ModelName                             $
T1_OriginalScore                        $
T1_TransformedScore                     $
T2_OriginalScore                        $
T2_TransformedScore                     $
FinalScore                              $
FinalTransformedScore                   $
HpmUnitPrice                            $
HpmTotalPrice                           $
HpmModelFlag                            $
StallFlag                               $
PolicyHousePrice                        $
PolicyStallPrice                        $
PolicyTotalPrice                        $
PolicyTotalPriceWithStall               $
FinalHousePrice                         $
FinalStallPrice                         $
FinalTotalPrice                         $
FinalTotalPriceWithStall                $
HierachyFlag                            $
%mend;

Data DGIS.outputjson_perf;
infile "&Local_file_Path.\csv\HPM_OUTPUT_perf.csv" FIRSTOBS=2 DELIMITER=',' MISSOVER DSD ;
format 
%fmt;
;
input
%inp;
;
run;

Data DGIS.outputjson_result;
infile "&Local_file_Path.\csv2\HPM_OUTPUT_result.csv" FIRSTOBS=2 DELIMITER=',' MISSOVER DSD ;
format 
%fmt;
;
input
%inp;
;
run;

proc sort data=DGIS.outputjson_perf;by no;run;
proc sort data=DGIS.outputjson_result;by no;run;

data dgis.DGIS_INPUTOUTPUT_&yyyymmdd.;
merge dgis.DGIS_INPUT
DGIS.outputjson_perf(in=perf)
DGIS.outputjson_result(in=result)
;
by no;
format outJsonSource $20.;
if perf then outJsonSource='perf';
if result then outJsonSource='result';
run;

systask command "c:\progra~2\7-zip\7z a -tzip &Local_file_Path.\&yyyymmdd._csv.zip &Local_file_Path.\csv\*" wait status=csv;
systask command "c:\progra~2\7-zip\7z a -tzip &Local_file_Path.\&yyyymmdd._csv2.zip &Local_file_Path.\csv2\*" wait status=csv2;
systask command "c:\progra~2\7-zip\7z a -tzip &Local_file_Path.\&yyyymmdd._json.zip &Local_file_Path.\json\*" wait status=json;
systask command "c:\progra~2\7-zip\7z a -tzip &Local_file_Path.\&yyyymmdd._json2.zip &Local_file_Path.\json2\*" wait status=json2;
