@IsTest
public class getSchedulingParametersTestClass{

    @IsTest
    static void validategetSchedulingParameters() {

        Map<String, SObject> testResourceMap = TestUtility.createSingleTestResource();

        Test.startTest();
        list<getSchedulingParameters.dataOut> dataOutList = getSchedulingParameters.getSchedulingParameters(new list<string>{testResourceMap.get('WorkType').id});
        Test.stopTest();

        System.assert(dataOutList.size() == 1);
        System.assert(dataOutList[0].wtgId != null);
    

    }



}