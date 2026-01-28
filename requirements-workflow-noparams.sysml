private import ScalarValues::*;

package RequirementManagementWorkflowNoParams {

    action def GenerateRequirementsProcess {
        
        first start;
        
        then action userInput {
            description = "Get a system description from the user.";
        }

        then loop action constructRequirementList  {

            action decompose {
                description = "A new requirement is generated based on the system description.";
            }

            then fork; then checkCorrectness; then checkNonRedundancy; then checkSatisfiability;
            
            action checkCorrectness {
                description = "Checks whether the new Requirement is correct based on the system description.";
            } then joinNode;

            action checkNonRedundancy {
                description = "Checks that the new requirement is not redundant based on the current list of accepted requirements";
            } then joinNode;

            action checkSatisfiability {
                description = "Checks whether the new requirement is satisfiable.";
            } then joinNode;

            then join joinNode;

            then action checkConsensus {
                description = "Validates if all previous checks are successful.";
            }

            then action updateRequirements {
                description = "Updates the list of accepted requirements and checks whether the list of accepted requirements is complete.";
                out isComplete : Boolean;
            }
        } until constructRequirementList.updateRequirements.isComplete;

        then action outputToUser {
            description = "Returns the list of completed requirements to the user.";
        }

        then done;
}}