classdef CandidateSpaceCombination < CandidateSpaceBase
    properties
        IndividualCandidateSpaces
    end

    properties (SetAccess = protected)
        DesignSampleDefinition
        IsInsideDefinition
        IsShapeDefinition
        Measure
        SamplingBox
    end

    methods
        function obj = CandidateSpaceCombination(varargin)
            obj.IndividualCandidateSpaces = horzcat(varargin{:});

            obj.DesignSpaceLowerBound = [];
            obj.DesignSpaceUpperBound = [];
            obj.SamplingBox = [];
            for i=1:length(obj.IndividualCandidateSpaces)
                obj.DesignSpaceLowerBound = [obj.DesignSpaceLowerBound, obj.IndividualCandidateSpaces(i).DesignSpaceLowerBound];
                obj.DesignSpaceUpperBound = [obj.DesignSpaceUpperBound, obj.IndividualCandidateSpaces(i).DesignSpaceUpperBound];
                obj.SamplingBox = [obj.SamplingBox, obj.IndividualCandidateSpaces(i).SamplingBox];
            end

            obj.DesignSampleDefinition = [];
            obj.IsInsideDefinition = [];
            obj.IsShapeDefinition = [];
            obj.Measure = [];
        end

        function [isInside,score] = is_in_candidate_space(obj,designSample)
            nCandidateSpace = length(obj.IndividualCandidateSpaces);
            scoreIndividual = zeros(size(designSample,1),nCandidateSpace);

            iDesignVariableDimension = 1;
            for i=1:nCandidateSpace
                nDesignVariableCurrent = size(obj.IndividualCandidateSpaces(i).DesignSpaceLowerBound,2);

                designSampleCurrent = designSample(:,iDesignVariableDimension + (0:(nDesignVariableCurrent-1)));
                [~,scoreIndividual(:,i)] = obj.IndividualCandidateSpaces(i).is_in_candidate_space(designSampleCurrent);

                iDesignVariableDimension = iDesignVariableDimension + nDesignVariableCurrent;
            end
            [isInside,score] = design_deficit_to_label_score(scoreIndividual);
        end

        function obj = generate_candidate_space(obj,~,~)
            error('CandidateSpaceCombination:generate_candidate_space:NotImplemented',...
                'generate_candidate_space is not implemented for CandidateSpaceCombination');
        end

        function obj = expand_candidate_space(obj,~)
            error('CandidateSpaceCombination:expand_candidate_space:NotImplemented',...
                'expand_candidate_space is not implemented for CandidateSpaceCombination');
        end
    end
end