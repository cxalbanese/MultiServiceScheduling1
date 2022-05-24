public class getSchedulingParameters {

//this class returns 2 values, a work type group id to be used for scheduling and a list of SR ids for resources that have the skills needed for the selected services
//in production, you will need another input parameter which is the selected territory id or geolocation so you can limit the query on STMs

@invocableMethod(label='Get scheduling WTG id and filtered SR Ids')
public static list<dataOut> getSchedulingParameters(list<string> inputWTIds) {

    dataOut dataO = new dataOut();
    dataO.srIds = null;    
    dataO.wtgId = null;
try{
    list<string> wtIdList = new list<string>(inputWTIds[0].split(';'));
    datetime startDateTime =  datetime.now();
    datetime endDateTime = startDateTime.adddays(7);
    list<serviceterritory> listST = new list<serviceterritory>();
    set<string> setSkillIdsRequired = new set<string>();
    list<serviceresourceskill> listSRSkill = new list<serviceresourceskill>();
    list<string> listSRId = new list<string>();
    set<string> setSRId = new set<string>();
    set<string> setSRIdwithSkills = new set<string>();
    //if its all territories just find all Active STs
    //get all of the active territories - this is really needed once you pass in territory id or geolocation
    listST = [select id from serviceterritory where isactive = true];
    //Get all of the skills required for all of the selected work types and add them to the set
    for(skill sk : [select id from skill where id in (select skillid from SkillRequirement where relatedrecordid in :wtIdList)]) setSkillIdsRequired.add(sk.id);
    //get list of all active stms in the selected territories 
    for(ServiceTerritoryMember stm :[SELECT EffectiveEndDate,EffectiveStartDate,Id,MemberNumber,ServiceResourceId,ServiceTerritoryId,TerritoryType FROM ServiceTerritoryMember where serviceterritoryid in :listST and
    ((EffectiveStartDate <= :startDateTime and EffectiveEndDate = null) or (EffectiveStartDate <= :startDateTime and EffectiveEndDate >= :endDateTime))]) setSRId.add(stm.ServiceResourceId);
    listSRSkill = [select id,ServiceResourceId from ServiceResourceSkill where ServiceResourceId in :setSRId and SkillId in :setSkillIdsRequired and ((EffectiveStartDate <= :startDateTime and EffectiveEndDate = null) or (EffectiveStartDate <= :startDateTime and EffectiveEndDate >= :endDateTime))];
    for(string srId : setSRId) {
        list<ServiceResourceSkill> listSRSRSkill = new list<ServiceResourceSkill>();
        for(ServiceResourceSkill srs : listSRSkill )
            if(srs.serviceresourceid == srId) listSRSRSkill.add(srs); 
        if (listSRSRSkill.size() >= setSkillIdsRequired.size()) setSRIdwithSkills.add(srId);
    }
    //get all of the selected service work types so we can total the durations
    list<worktype> listWTServices = new list<worktype>([select id, durationinminutes from worktype where type__c = 'service' and id in :wtIdList]);
    decimal totalDuration = 0;
    for(worktype wt :   listWTServices) totalduration+=wt.durationinminutes;  
    //get all of the scheduling work types so we can select the 1 large enough to handle the selected services    
    list<worktype> listWTScheduling = new list<worktype>([select id, durationinminutes from worktype where type__c = 'scheduling' and durationinminutes>=:totalduration order by durationinminutes asc]);
    if(listWTScheduling.size()>0) 
        dataO.wtgId = [select WorkTypeGroupId from WorkTypeGroupMember where worktypeid = :listWTScheduling[0].id limit 1].WorkTypeGroupId;
    else {
        //if there is not 1 large enough to handle the selected services just return the largest 1
        worktype maxWTScheduling = [select id, durationinminutes from worktype where type__c = 'scheduling' order by durationinminutes desc limit 1];
        dataO.wtgId = [select WorkTypeGroupId from WorkTypeGroupMember where worktypeid in (select id from worktype where id = :maxWTScheduling.id)].worktypegroupid;
    }
    //this next block of code will ensure that there are <= 50 service resource ids contained in the csv string. 
    integer limitcounter = 1;
    set<string> limitedsetSRIdwithSkills = new set<string>();
    for(string thesrId : setSRIdwithSkills)  {
        if(limitcounter<=50) limitedsetSRIdwithSkills.add(thesrId);
        limitcounter++;
    }
    //this next block of code builds the list of comma separated service resource ids and ensures the last sr id is not followed by a comma
    integer counter = 0;
    for(string srid : limitedsetSRIdwithSkills) {        
        if(counter==0) dataO.srIds=srid; else dataO.srIds+= srid;    
        counter++;
        if(counter < limitedsetSRIdwithSkills.size()) dataO.srIds+=',';
    }
    return new list<dataOut>{dataO};
    }
catch(exception e) {
    return new list<dataOut>{dataO};            
    }    
}

public class dataOut {
    @invocableVariable(label = 'Scheduling WTG Id') 
    public string wtgId;
    @invocableVariable(label = 'Filtered SR Ids') 
    public string srIds;
}

}