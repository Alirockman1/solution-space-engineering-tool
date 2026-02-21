classdef BottomUpMappingFastForward < BottomUpMappingBase
%BOTTOMUPMAPPINGFASTFORWARD Design Evaluator that uses Fast Forward models
%   BOTTOMUPMAPPINGFASTFORWARD takes bottom-up mapping functions and adapts the 
%   interface calls so they may also work as bottom-up mappings.
%
%   This class is derived from BottomUpMappingBase.
%
%   BOTTOMUPMAPPINGFASTFORWARD methods:
%       - response : a function that receives the design samples and returns 
%       the system response for those variables in terms of performance and physical feasibility.
%
%   See also BottomUpMappingBase.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2023-2025.
%   Copyright 2023-2025 Eduardo Rodrigues Della Noce
%   SPDX-License-Identifier: Apache-2.0

%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
% 
%       http://www.apache.org/licenses/LICENSE-2.0
% 
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.

    properties(SetAccess = protected)
        %MODELPERFORMANCE Bottom-up Mapping Function used to predict performance
        %   MODELPERFORMANCE is the bottom-up mapping function used to predict
        %   the performance of a given design.
        %
        %   MODELPERFORMANCE : BottomUpMappingFunction object
        %   
        %   See also BottomUpMappingFunction, response.
        ModelPerformance
        
        %MODELPHYSICALFEASIBILITY Bottom-up Mapping Function used to predict physical feasibility
        %   MODELPHYSICALFEASIBILITY is the bottom-up mapping function used to predict
        %   the physical feasibility of a given design.
        %
        %   MODELPHYSICALFEASIBILITY : BottomUpMappingFunction object
        %   
        %   See also BottomUpMappingFunction, response.
        ModelPhysicalFeasibility

        PerformanceDefaultValue

        PhysicalFeasibilityDefaultValue
    end
    
    methods
        function obj = BottomUpMappingFastForward(varargin)
        %BOTTOMUPMAPPINGFASTFORWARD Constructor
        %   BOTTOMUPMAPPINGFASTFORWARD uses bottom-up mapping functions to 
        %   create a bottom-up mapping.
        %
        %   OBJ = BOTTOMUPMAPPINGFASTFORWARD(MODELPERFORMANCE) uses the bottom-up
        %   mapping function specified in MODELPERFORMANCE to create a new object of
        %   the BottomUpMappingFastForward class in OBJ. Said object uses the 
        %   bottom-up mapping function to predict the performance and physical feasibility
        %   of a given design when the 'response' method is called.
        %
        %   OBJ = BOTTOMUPMAPPINGFASTFORWARD(MODELPERFORMANCE,MODELPHYSICALFEASIBILITY) 
        %   also takes a second bottom-up mapping function given in MODELPHYSICALFEASIBILITY and
        %   uses it to determine the physical feasibility of designs when the 'response'
        %   method is called. 
        %
        %   Input:
        %       - MODELPERFORMANCE : BottomUpMappingFunction
        %       - MODELPHYSICALFEASIBILITY : BottomUpMappingFunction
        %   
        %   Output:
        %       - OBJ : BottomUpMappingFastForward
        %   
        %   See also response.

            parser = inputParser;
            parser.addOptional('ModelPerformance',[]);
            parser.addOptional('ModelPhysicalFeasibility',[]);
            parser.addParameter('PerformanceDefaultValue',[]);
            parser.addParameter('PhysicalFeasibilityDefaultValue',[]);
            parser.parse(varargin{:});

            obj.ModelPerformance = parser.Results.ModelPerformance;
            obj.ModelPhysicalFeasibility = parser.Results.ModelPhysicalFeasibility;
            obj.PerformanceDefaultValue = parser.Results.PerformanceDefaultValue;
            obj.PhysicalFeasibilityDefaultValue = parser.Results.PhysicalFeasibilityDefaultValue;
        end
        
        function [performanceMeasure,physicalFeasibilityMeasure,evaluationOutput] = response(obj,designSample)
        %   [PERFORMANCEMEASURE,PHYSICALFEASIBILITYMEASURE,RESPONSEOUTPUT] = 
        %   OBJ.RESPONSE(...) also returns any more information from the response
        %   process in RESPONSEOUTPUT; in this case, that is the outputs
        %   of the predictions of the bottom-up mapping functions.
        %
        %   Inputs:
        %       - OBJ : BottomUpMappingFastForward
        %       - DESIGNSAMPLE : (nSample,nDesignVariable) double
        %   
        %   Outputs:
        %       - PERFORMANCEMEASURE : (nSample,nPerformance) double
        %       - PHYSICALFEASIBILITYMEASURE : (nSample,nPhysicalFeasibility) double
        %       - RESPONSEOUTPUT : structure
        %           -- PerformanceOutput : class-defined
        %           -- PhysicalFeasibilityOutput : class-defined
        %   
        %   See also BottomUpMappingFastForward.

            % performance prediction
            if(~isempty(obj.ModelPerformance))
                [performanceMeasure,performanceOutput] = obj.ModelPerformance.predict_design_measure(designSample);
            else
                % no model, assume all good
                performanceMeasure = repmat(obj.PerformanceDefaultValue,size(designSample,1),1);
                performanceOutput = [];
            end

            % physical feasibility prediction
            if(~isempty(obj.ModelPhysicalFeasibility))
                [physicalFeasibilityMeasure,physicalFeasibilityOutput] = obj.ModelPhysicalFeasibility.predict_design_measure(designSample);
            else
                % no model, assume all physically feasible
                physicalFeasibilityMeasure = repmat(obj.PhysicalFeasibilityDefaultValue,size(designSample,1),1);
                physicalFeasibilityOutput = [];
            end

            % wrap outputs
            evaluationOutput.PerformanceOutput = performanceOutput;
            evaluationOutput.PhysicalFeasibilityOutput = physicalFeasibilityOutput;
        end
    end
end