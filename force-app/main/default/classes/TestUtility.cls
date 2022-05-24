@isTest
public with sharing class TestUtility {
    public TestUtility() {

    }

    public static WorkType createWorktype(String worktypeName, Double estDuration, String durationType, String Type){

        WorkType testWorkType = new WorkType(Name = worktypeName,
                                            EstimatedDuration = estDuration,
                                            DurationType = durationType,
                                            Type__c = Type);

        insert testWorkType;                            
        return testWorkType;

    }
    public static WorkTypeGroup createWorkTypeGroup(String worktypegroupName){

        WorkTypeGroup testWorkTypeGroup = new WorkTypeGroup(Name = worktypegroupName,
                                            IsActive=True);

        insert testWorkTypeGroup;                   
        return testWorkTypeGroup;

    }
    public static WorkTypeGroupMember createWorkTypeGroupMember(String wtgId, String wtId){

        WorkTypeGroupMember testWTGM = new WorkTypeGroupMember(WorkTypeGroupId = wtgId,
                                                                    WorkTypeId = wtId);

        insert testWTGM;
        return testWTGM;

    }
    public static ServiceTerritoryWorkType createServiceTerritoryWorkType(String stId, String wtId){

        ServiceTerritoryWorkType testSTWT = new ServiceTerritoryWorkType(ServiceTerritoryId = stId,
                                                                    WorkTypeId = wtId);

        insert testSTWT;
        return testSTWT;
    }

    public static OperatingHours createOperatingHours(String ohName){

        OperatingHours testOperatingHours = new OperatingHours(Name = ohName);
        
        insert testOperatingHours;
        return testOperatingHours;

    }

    public static OperatingHours createOperatingHours(String ohName, String tz){

        OperatingHours testOperatingHours = new OperatingHours(Name = ohName, 
                                                               TimeZone = tz);
        
        insert testOperatingHours;
        return testOperatingHours;

    }


    public static ServiceTerritory createServiceTerritory(String territoryName,Boolean active, String opHoursId){

        ServiceTerritory testServiceTerritory = new ServiceTerritory(Name = territoryName,
                                                                     IsActive = active,
                                                                     OperatingHoursId = opHoursId);

        insert testServiceTerritory;
        return testServiceTerritory;

    }


    public static ServiceResource createServiceResource(String resourceName, Boolean active, String relatedRecord, String resourceType){

        ServiceResource testServiceResource = new ServiceResource(Name = resourceName,
                                                                  IsActive = active,
                                                                  relatedRecordId = relatedRecord,
                                                                  ResourceType = resourceType);

        insert testServiceResource;
        return testServiceResource;

    }


    public static ServiceTerritoryMember createServiceTerritoryMember(String resourceId, String territoryId, Datetime startDate){

        ServiceTerritoryMember testStm = new ServiceTerritoryMember(ServiceResourceid = resourceId,
                                                                    ServiceTerritoryId = territoryId,
                                                                    EffectiveStartDate = startDate);

        insert testStm;
        return testStm;

    }

      
     public static ServiceResourceSkill createServiceResourceSkill(String serviceResourceId){

        Skill testSkill = [SELECT Id FROM Skill LIMIT 1];

        ServiceResourceSkill resourceSkill = new ServiceResourceSkill(ServiceResourceId = serviceResourceId, SkillId = testSkill.Id, EffectiveStartDate = Datetime.now().addDays(-10));
        insert resourceSkill;
        return resourceSkill;

    }
    
     public static SkillRequirement createSkillRequirement(String workTypeId){

        Skill testSkill = [SELECT Id FROM Skill LIMIT 1];

        SkillRequirement wtSkill = new SkillRequirement(RelatedRecordId = workTypeId, SkillId = testSkill.Id);
        insert wtSkill;
        return wtSkill;

    }

    public static Map<String,SObject> createSingleTestResource(){

        String objectName = '';
        Map<String, SObject> testResourceObjectMap = new Map<String, SObject>();
        String testName = 'test' + String.valueOf(Crypto.getRandomInteger());

        WorkType testWorkType = createWorkType(testName, 1, 'hours','Service');
        objectName = 'WorkType';
        testResourceObjectMap.put(objectName, testWorkType);

        WorkType testWorkTypeSched = createWorkType(testName, 1, 'hours','Scheduling');
        objectName = 'WorkTypeSched';
        testResourceObjectMap.put(objectName, testWorkTypeSched);
        
        WorkTypeGroup testWorkTypeGroup = createWorkTypeGroup(testName);
        objectName = 'WorkTypeGroup';
        testResourceObjectMap.put(objectName, testWorkTypeGroup);        
        
        OperatingHours testOh = createOperatingHours(testName);
        objectName = 'OperatingHours';
        testResourceObjectMap.put(objectName, testOh);

        ServiceTerritory testTerritory = createServiceTerritory(testName, true, testOh.Id);
        objectName = 'ServiceTerritory';
        testResourceObjectMap.put(objectName, testTerritory);

        ServiceResource testResource = createServiceResource(testName, true, createUser(1)[0].id, 'T');
        objectName = 'ServiceResource';
        testResourceObjectMap.put(objectName, testResource);

        ServiceTerritoryMember testSTM = createServiceTerritoryMember(testResource.Id, testTerritory.Id, datetime.now());
        objectName = 'ServiceTerritoryMember';        
        testResourceObjectMap.put(objectName, testSTM);
        
        WorkTypeGroupMember testWTGM = createWorkTypeGroupMember(testResourceObjectMap.get('WorkTypeGroup').id,testResourceObjectMap.get('WorkTypeSched').id);
        objectName = 'WorkTypeGroupMember';        
        testResourceObjectMap.put(objectName, testWTGM);
            
        ServiceTerritoryWorkType testSTWT = createServiceTerritoryWorkType(testResourceObjectMap.get('ServiceTerritory').id,testResourceObjectMap.get('WorkType').id);
        objectName = 'WorkTypeGroupMember';        
        testResourceObjectMap.put(objectName, testWTGM);    
        
        ServiceResourceSkill testSRS = createServiceResourceSkill(testResourceObjectMap.get('ServiceResource').id);
        objectName = 'ServiceResourceSkill';        
        testResourceObjectMap.put(objectName, testSRS);              
            
        SkillRequirement testWTS = createSkillRequirement(testResourceObjectMap.get('WorkType').id);
        objectName = 'WorkTypeSkill';        
        testResourceObjectMap.put(objectName, testWTS);           
        
        return testResourceObjectMap;

    }


    public static List<User> createUser(Integer numberOfUsersToCreate){

        List<User> testUserList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Integer i = 0;

        while(i < numberOfUsersToCreate){

            User u = new User(Alias = 'standt' + i, 
                          Email='standarduser' + i + '@example.com', 
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser' + i + '@ecatest001.com');

            testUserList.add(u);

            i++;

        }

        insert testUserList;
        return testUserList;

    }





}