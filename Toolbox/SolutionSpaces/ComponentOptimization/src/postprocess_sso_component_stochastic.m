function algorithmData = postprocess_sso_component_stochastic(optimizationData)
%POSTPROCESS_SSO_COMPONENT_STOCHASTIC Postprocess for stochastic component SSO
%   POSTPROCESS_SSO_COMPONENT_STOCHASTIC extracts the most important information  
%   from the data outputs of the SSO stochastic method for components and 
%   packages it as individual arrays for each iteration step. This allows for 
%   easy plotting and verification of said data afterwards.
%
%   ALGORITHMDATA = POSTPROCESS_SSO_COMPONENT_STOCHASTIC(PROBLEMDATA, 
%   ITERATIONDATA) receives the data outputs of the SSO stochastic method for
%   components in PROBLEMDATA and ITERATIONDATA and returns the structure with 
%   information arrays in ALGORITHMDATA. PROBLEMDATA should contain all 
%   information that is fixed / the same for all iterations, and ITERATIONDATA 
%   should be a structure array with the information that changes each 
%   iteration.
%
%   Inputs:
%       - PROBLEMDATA : structure
%       - ITERATIONDATA : (nIter, 1) structure
%
%   Outputs:
%       - ALGORITHMDATA : structure
%           -- IndexExplorationStart : integer
%           -- IndexExplorationEnd : integer
%           -- IndexConsolidationStart : integer
%           -- IndexConsolidationEnd : integer
%           -- IsUsingRequirementSpaces : logical
%           -- GrowthRate : (nIter,1) double
%           -- NumberEvaluatedSamples : (nIter,1) integer
%           -- NumberPaddingSamplesGenerated : (nIter,1) integer
%           -- NumberPaddingSamplesUsed : (nIter,1) integer
%           -- NumberGoodDesigns : (nIter,1) integer
%           -- NumberPhysicallyFeasibleDesigns : (nIter,1) integer
%           -- NumberAcceptableAndUsefulDesigns : (nIter,1) integer
%           -- NumberAcceptableDesigns : (nIter,1) integer
%           -- NumberUsefulDesigns : (nIter,1) integer
%           -- AlgorithmPhase : (nIter,1) integer
%           -- AlgorithmPhaseIterationNumber : (nIter,1) integer
%           -- ComponentMeasureBeforeTrim : (nIter,nComponent) double
%           -- ComponentMeasureBeforeTrimNormalized : (nIter,nComponent) double
%           -- ComponentMeasureAfterTrim : (nIter,nComponent) double
%           -- ComponentMeasureAfterTrimNormalized : (nIter,nComponent) double
%           -- TotalMeasureBeforeTrim : (nIter,1) double
%           -- TotalMeasureBeforeTrimNormalized : (nIter,1) double
%           -- TotalMeasureAfterTrim : (nIter,1) double
%           -- TotalMeasureAfterTrimNormalized : (nIter,1) double
%           -- TotalFunctionEvaluations : (nIter,1) integer
%           -- SamplePurity : (nIter,1) double
%           -- RatioComponentMeasureChangeBeforeTrim : (nIter,nComponent) double
%           -- RatioComponentMeasureChangeAfterTrim : (nIter,nComponent) double
%           -- RatioTotalMeasureChangeBeforeTrim : (nIter,1) double
%           -- RatioTotalMeasureChangeAfterTrim : (nIter,1) double
%           -- RatioPadding : (nIter,1) double
%
%   See also sso_component_stochastic, plot_sso_component_stochastic_metrics.

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

	designSpaceLowerBound = optimizationData.DesignSpaceLowerBound;
    designSpaceUpperBound = optimizationData.DesignSpaceUpperBound;
    
    % algorithm data
    iExplorationStart = 1;
    iConsolidationStart = find([optimizationData.IterationData.Phase]==2,1,'first');
    iExplorationEnd = iConsolidationStart-1;
    iConsolidationEnd = length(optimizationData.IterationData);
    
    % requirement spaces plots only necessary if there are useless designs
    if(all([optimizationData.IterationData.IsUseful],'all'))
        flagReqSpaces = false;
    else
        flagReqSpaces = true;
    end
    
    % create column arrays
    phase = [optimizationData.IterationData.Phase]';
    growthRate = [optimizationData.IterationData.GrowthRate]';
    nSample = [optimizationData.IterationData.NumberEvaluatedSamples]';
    nPadGenerated = [optimizationData.IterationData.NumberPaddingSamplesGenerated]';
    nPadUsed = [optimizationData.IterationData.NumberPaddingSamplesGenerated]'; % FIX LATER, NOT LOGGED CURRENTLY
    nGood = [optimizationData.IterationData.NumberGoodDesigns]';
    nPhysicallyFeasible = [optimizationData.IterationData.NumberPhysicallyFeasibleDesigns]';
    nAccUse = [optimizationData.IterationData.NumberAcceptableAndUsefulDesigns]';
    nAcc = [optimizationData.IterationData.NumberAcceptableDesigns]';
    nUse = [optimizationData.IterationData.NumberUsefulDesigns]';
    timeElapsedAdaptGrowthRate = [optimizationData.IterationData.TimeElapsedAdaptGrowthRate]';
    timeElapsedGrow = [optimizationData.IterationData.TimeElapsedGrow]';
    timeElapsedGenerate = [optimizationData.IterationData.TimeElapsedGenerate]';
    timeElapsedEvaluate = [optimizationData.IterationData.TimeElapsedEvaluate]';
    timeElapsedLabel = [optimizationData.IterationData.TimeElapsedLabel]';
    timeElapsedCount = [optimizationData.IterationData.TimeElapsedCount]';
    timeElapsedShape = [optimizationData.IterationData.TimeElapsedShape]';
    timeElapsedPrepare = [optimizationData.IterationData.TimeElapsedPrepare]';
    timeElapsedTrimmingOrder = [optimizationData.IterationData.TimeElapsedTrimmingOrder]';
    timeElapsedTrim = [optimizationData.IterationData.TimeElapsedTrim]';
    timeElapsedLeanness = [optimizationData.IterationData.TimeElapsedLeanness]';
    timeElapsedMeasure = [optimizationData.IterationData.TimeElapsedMeasure]';
    timeElapsedConvergence = [optimizationData.IterationData.TimeElapsedConvergence]';
    timeElapsedIteration = [optimizationData.IterationData.TimeElapsedIteration]';
    
    % get measures
    designSpaceMeasure = prod(designSpaceUpperBound - designSpaceLowerBound);

    componentIndex = optimizationData.ComponentIndex;
    nComponent = size(componentIndex,2);
    designSpaceMeasureComponent = nan(1,nComponent);
    for iComponent = 1:nComponent
        designSpaceMeasureComponent(iComponent) = prod(designSpaceUpperBound(componentIndex{iComponent}) - designSpaceLowerBound(componentIndex{iComponent}));
    end

    componentMeasuresBeforeTrim = nan(iConsolidationEnd,nComponent);
    componentMeasuresAfterTrim = nan(iConsolidationEnd,nComponent);
    for i=1:iConsolidationEnd
        for j=1:nComponent
            componentMeasuresBeforeTrim(i,j) = optimizationData.IterationData(i).ComponentMeasureBeforeTrim(j);
            componentMeasuresAfterTrim(i,j) = optimizationData.IterationData(i).ComponentMeasureAfterTrim(j);
        end
    end
    componentMeasuresBeforeTrimNormalized = componentMeasuresBeforeTrim./designSpaceMeasureComponent;
    componentMeasuresAfterTrimNormalized = componentMeasuresAfterTrim./designSpaceMeasureComponent;
    
    measureBeforeTrim = prod(componentMeasuresBeforeTrim,2);
    measureAfterTrim = prod(componentMeasuresAfterTrim,2);
    measureBeforeTrimNormalized = measureBeforeTrim./designSpaceMeasure;
    measureAfterTrimNormalized = measureAfterTrim./designSpaceMeasure;

    % 
    phaseIterNumber = [1:iExplorationEnd , ...
        (iConsolidationStart:iConsolidationEnd)-iConsolidationStart+1]';

    % further information
    totalEvaluations = cumsum(nSample);
    purity = nAcc./nSample;
    ratioComponentMeasureChangeBeforeTrim = componentMeasuresBeforeTrim./...
        [zeros(1,nComponent);componentMeasuresBeforeTrim(1:end-1,:)];
    ratioComponentMeasureChangeAfterTrim = componentMeasuresAfterTrim./...
        [zeros(1,nComponent);componentMeasuresAfterTrim(1:end-1,:)];
    ratioTotalMeasureChangeBeforeTrim = measureBeforeTrim./[0;measureBeforeTrim(1:end-1)];
    ratioTotalMeasureChangeAfterTrim = measureAfterTrim./[0;measureAfterTrim(1:end-1)];
    ratioPaddingSamples = nPadUsed./(nPadUsed+nSample);
    totalTimeElapsed = cumsum(timeElapsedIteration);

    % wrap
    algorithmData = struct(...
    	'IndexExplorationStart',iExplorationStart,...
    	'IndexExplorationEnd',iExplorationEnd,...
    	'IndexConsolidationStart',iConsolidationStart,...
    	'IndexConsolidationEnd',iConsolidationEnd,...
    	'IsUsingRequirementSpaces',flagReqSpaces,...
    	'GrowthRate',growthRate,...
    	'NumberEvaluatedSamples',nSample,...
    	'NumberPaddingSamplesGenerated',nPadGenerated,...
    	'NumberPaddingSamplesUsed',nPadUsed,...
        'NumberGoodDesigns',nGood,...
        'NumberPhysicallyFeasibleDesigns',nPhysicallyFeasible,...
    	'NumberAcceptableAndUsefulDesigns',nAccUse,...
    	'NumberAcceptableDesigns',nAcc,...
    	'NumberUsefulDesigns',nUse,...
    	'AlgorithmPhase',phase,...
    	'AlgorithmPhaseIterationNumber',phaseIterNumber,...
    	'ComponentMeasureBeforeTrim',componentMeasuresBeforeTrim,...
    	'ComponentMeasureBeforeTrimNormalized',componentMeasuresBeforeTrimNormalized,...
    	'ComponentMeasureAfterTrim',componentMeasuresAfterTrim,...
    	'ComponentMeasureAfterTrimNormalized',componentMeasuresAfterTrimNormalized,...
    	'TotalMeasureBeforeTrim',measureBeforeTrim,...
    	'TotalMeasureBeforeTrimNormalized',measureBeforeTrimNormalized,...
    	'TotalMeasureAfterTrim',measureAfterTrim,...
    	'TotalMeasureAfterTrimNormalized',measureAfterTrimNormalized,...
    	'TotalFunctionEvaluations',totalEvaluations,...
    	'SamplePurity',purity,...
        'RatioComponentMeasureChangeBeforeTrim',ratioComponentMeasureChangeBeforeTrim,...
        'RatioComponentMeasureChangeAfterTrim',ratioComponentMeasureChangeAfterTrim,...
    	'RatioTotalMeasureChangeBeforeTrim',ratioTotalMeasureChangeBeforeTrim,...
    	'RatioTotalMeasureChangeAfterTrim',ratioTotalMeasureChangeAfterTrim,...
    	'RatioPadding',ratioPaddingSamples,...
        'TotalTimeElapsed',totalTimeElapsed,...
        'TimeElapsedAdaptGrowthRate',timeElapsedAdaptGrowthRate,...
        'TimeElapsedGrow',timeElapsedGrow,...
        'TimeElapsedGenerate',timeElapsedGenerate,...
        'TimeElapsedEvaluate',timeElapsedEvaluate,...
        'TimeElapsedLabel',timeElapsedLabel,...
        'TimeElapsedCount',timeElapsedCount,...
        'TimeElapsedShape',timeElapsedShape,...
        'TimeElapsedPrepare',timeElapsedPrepare,...
        'TimeElapsedTrimmingOrder',timeElapsedTrimmingOrder,...
        'TimeElapsedTrim',timeElapsedTrim,...
        'TimeElapsedLeanness',timeElapsedLeanness,...
        'TimeElapsedMeasure',timeElapsedMeasure,...
        'TimeElapsedConvergence',timeElapsedConvergence,...
        'TimeElapsedIteration',timeElapsedIteration);
end