classdef CandidateSpaceAnalyticalTest < CandidateSpaceBase
% ONLY TO BE USED FOR TESTING PURPOSES

    properties
        ScoreFunction
        ScoreFunctionParameters
    end

    properties (SetAccess = protected)
        DesignSampleDefinition
        IsInsideDefinition
        IsShapeDefinition
        Measure
        SamplingBox
    end

    methods
        function obj = CandidateSpaceAnalyticalTest(designSpaceLowerBound,designSpaceUpperBound,varargin)
            parser = inputParser;
            parser.addParameter('ScoreFunction',[],@(x)isa(x,'function_handle')||isempty(x));
            parser.addParameter('ScoreFunctionParameters',{},@(x)iscell(x));
            parser.addParameter('SamplingBox',[],@(x)isnumeric(x)&&(size(x,1)==2)&&(size(x,2)==size(designSpaceLowerBound,2)));
            parser.parse(varargin{:});

            obj.DesignSpaceLowerBound = designSpaceLowerBound;
            obj.DesignSpaceUpperBound = designSpaceUpperBound;
            
            if(isempty(parser.Results.SamplingBox))
                obj.SamplingBox = [designSpaceLowerBound;designSpaceUpperBound];
            else
                obj.SamplingBox = parser.Results.SamplingBox;
            end

            obj.ScoreFunction = parser.Results.ScoreFunction;
            obj.ScoreFunctionParameters = parser.Results.ScoreFunctionParameters;

            obj.DesignSampleDefinition = [];
            obj.IsInsideDefinition = [];
            obj.IsShapeDefinition = [];
            obj.Measure = [];
        end

        function [isInside,score] = is_in_candidate_space(obj,designSample)
            [isInside,score] = is_in_design_box(designSample,obj.SamplingBox);
            
            if(~isempty(obj.ScoreFunction))
                score = max(score,obj.ScoreFunction(designSample,obj.ScoreFunctionParameters{:}));
                isInside = (score<=0);
            end
        end

        function obj = generate_candidate_space(obj,~,~)
            error('CandidateSpaceAnalyticalTest:generate_candidate_space:NotImplemented',...
                'generate_candidate_space is not implemented for CandidateSpaceAnalyticalTest');
        end

        function obj = expand_candidate_space(obj,~)
            error('CandidateSpaceAnalyticalTest:expand_candidate_space:NotImplemented',...
                'expand_candidate_space is not implemented for CandidateSpaceAnalyticalTest');
        end
    end
end