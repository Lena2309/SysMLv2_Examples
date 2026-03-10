package RequirementManagementAgentsNoParams {
    private import ScalarValues::*;
    private import SequenceFunctions::*;
    private import MOSAICO::*;
    private import Collections::*;

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
        first start;

        then action userInput : AgentStep {
            :>> description = "Get a system description from the user.";
            :>> agent = referenceAgent;
        }

        then loop action constructRequirementList {
            action decompose : AgentStep {
                :>> description = "A new requirement is generated based on the system description.";
                :>> agent = requirementManagerAgent;
            }

            then fork;
                then replicateCorrectness;
                then checkNonRedundancy;
                then checkSatisfiability;

            action replicateCorrectness : ReplicationStep {
                :>> agents = (checkCorrectnessAgent);
                :>> repetitions = (10);
                :>> prompts = ("Replicates the correctness check to multiple agents.");

                action checkCorrectness : AgentStep {
                    :>> description =
                        "Checks whether the new Requirement is correct based on the system description.";
                }
            }
            then joinNode;
            

            action checkNonRedundancy : AgentStep {
                :>> description =
                    "Checks that the new requirement is not redundant based on the current list of accepted requirements";
            }
            then joinNode;

            action checkSatisfiability : AgentStep {
                :>> description = "Checks whether the new requirement is satisfiable.";
            }
            then joinNode;

            join joinNode;

            then action checkConsensus : AgentStep {
                :>> agent = consensusAgent;
            }

            then action updateRequirements : AgentStep {
                :>> description =
                    "Updates the list of accepted requirements and checks whether the list of accepted requirements is complete.";
                :>> agent = requirementManagerAgent;
                out isComplete : Boolean;
            }
        } until constructRequirementList.updateRequirements.isComplete;

        then action outputToUser : AgentStep {
            :>> description = "Returns the list of completed requirements to the user.";
            :>> agent = referenceAgent;
        }

        then done;
    }
}
