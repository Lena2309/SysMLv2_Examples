package RequirementManagementAgentsNoParamsFlat {
    private import ScalarValues::*;
    private import SequenceFunctions::*;
    private import MOSAICO::*;

    part def RequirementManagerAgent specializes SolutionAgent {
        :>> id = "eu.mosaico-project.requirement-manager-agent-type.v1";
        constraint { licences->includes("MIT") }
    }

    part def CheckCorrectNessAgent specializes SupervisionAgent {
        :>> id = "eu.mosaico-project.check-correctness-agent-type.v1";
    }

    part def CheckNonRedundancyAgent specializes SupervisionAgent {
        :>> id = "eu.mosaico-project.check-non-redundancy-agent-type.v1";
    }

    part def CheckSatisfiabilityAgent specializes SupervisionAgent {
        :>> id = "eu.mosaico-project.check-satisfiability-agent-type.v1";
    }

    referenceAgent : ReferenceAgent;
    requirementManagerAgent : RequirementManagerAgent;
    checkCorrectnessAgent : CheckCorrectNessAgent;
    checkNonRedundancyAgent : CheckNonRedundancyAgent;
    checkSatisfiabilityAgent : CheckSatisfiabilityAgent;
    consensusAgent : ConsensusAgent;

    action def GenerateRequirementsProcess {

        action userInput : AgentStep {
            :>> description = "Get a system description from the user.";
            :>> agent = referenceAgent;
        }

        action decompose : AgentStep {
            :>> description = "A new requirement is generated based on the system description.";
            :>> agent = requirementManagerAgent;
        }

        fork forkNode;

        action checkCorrectness : AgentStep {
            :>> description =
                "Checks whether the new Requirement is correct based on the system description.";
        }

        action checkNonRedundancy : AgentStep {
            :>> description =
                "Checks that the new requirement is not redundant based on the current list of accepted requirements";
        }

        action checkSatisfiability : AgentStep {
            :>> description = "Checks whether the new requirement is satisfiable.";
        }

        join joinNode;

        action checkConsensus : AgentStep {
            :>> agent = consensusAgent;
        }

        action updateRequirements : AgentStep {
            :>> description =
                "Updates the list of accepted requirements and checks whether the list of accepted requirements is complete.";
            :>> agent = requirementManagerAgent;
            out isComplete : Boolean;
        }

        decide decisionNode ;

        action outputToUser : AgentStep {
            :>> description = "Returns the list of completed requirements to the user.";
            :>> agent = referenceAgent;
        }

        first start then userInput;
        first userInput then decompose;
        first decompose then forkNode;
        first forkNode then checkCorrectness;
        first forkNode then checkNonRedundancy;
        first forkNode then checkSatisfiability;
        first checkCorrectness then joinNode;
        first checkNonRedundancy then joinNode;
        first checkSatisfiability then joinNode;
        first joinNode then checkConsensus;
        first checkConsensus then updateRequirements;
        first updateRequirements then decisionNode;
        first decisionNode; 
            if updateRequirements.isComplete then outputToUser;
            else decompose;
        first outputToUser then done;
    }
}