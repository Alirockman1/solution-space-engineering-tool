classdef CandidateSpaceCornerBoxRemoval < CandidateSpaceBase
%CANDIDATESPACECORNERBOXREMOVAL Candidate Space using corner-box removal
%   CANDIDATESPACECORNERBOXREMOVAL defines a candidate space by removing
%   certain "corner boxes" from the feasible region. These corner boxes are
%   identified via anchor points and a corner-direction logic, and designs
%   that lie inside these boxes are excluded from the candidate space. 
%
%   CANDIDATESPACECORNERBOXREMOVAL is derived from CandidateSpaceBase.
%
%   CANDIDATESPACECORNERBOXREMOVAL properties:
%       - DesignSampleDefinition : sample points used to define the candidate 
%       space.
%       - IsInsideDefinition : logical flags specifying whether each sample 
%       point is inside or outside the space (true = inside).
%       - AnchorPoint : anchor points that determine the corners to remove.
%       - CornerDirection : directions specifying how each anchor trims the 
%       space.
%       - DetachTolerance : tolerance for merging or discarding anchors.
%       - IsShapeDefinition : logical flags indicating which points directly 
%       shape the boundary of the candidate space.
%       - Measure : approximate measure (area/volume) of the candidate space.
%       - SamplingBox : bounding box around the current inside region for 
%       sampling.
%
%   CANDIDATESPACECORNERBOXREMOVAL methods:
%       - generate_candidate_space : initialize the candidate space using sample 
%       points and trimming information (anchors/corners).
%       - update_candidate_space : update the definition with new samples, 
%       possibly adding or removing corner anchors.
%       - expand_candidate_space : grow the space by a factor within the design
%       space.
%       - is_in_candidate_space : determine whether new points are inside the 
%       space.
%
%   See also: CandidateSpaceBase.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2024-2025.
%   Copyright 2024-2025 Eduardo Rodrigues Della Noce
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

    properties (SetAccess = protected)
        %DESIGNSAMPLEDEFINITION Design sample points used in candidate space definition
        %   DESIGNSAMPLEDEFINITION are the sample points used in the definition of the 
        %   current candidate space.
        %
        %   DESIGNSAMPLEDEFINITION : (nSample,nDesignVariable) double
        %
        %   See also IsInsideDefinition, IsShapeDefinition.
        DesignSampleDefinition

        %ISINSIDEDEFINITION Labels of sample points used in candidate space definition
        %   ISINSIDEDEFINITION are the labels of design samples used in the definition 
        %   of the current candidate space. A label of 'true' indicates the respective 
        %   design point is inside the candidate space.
        %
        %   ISINSIDEDEFINITION : (nSample,1) logical
        %
        %   See also DesignSampleDefinition, IsShapeDefinition.
        IsInsideDefinition
        
        %ANCHORPOINT Anchor points used to define corner regions to remove
        %   ANCHORPOINT represents specific reference points that, combined with 
        %   CornerDirection, identify which corner boxes (i.e., rectangular subregions)
        %   in the design space should be removed.
        %
        %   ANCHORPOINT : (nAnchor, nDesignVariable) double
        %
        %   See also CornerDirection, generate_candidate_space.
        AnchorPoint

        %CORNERDIRECTION Corner-direction flags specifying the removal region
        %   CORNERDIRECTION is an array of booleans indicating for each dimension 
        %   whether the corner is "upper" or "lower." If true in dimension j, the 
        %   removal corner extends toward the upper boundary in that dimension, else 
        %   it extends toward the lower boundary.
        %
        %   CORNERDIRECTION : (nAnchor, nDesignVariable) logical
        %
        %   See also AnchorPoint.
        CornerDirection

        %DETACHTOLERANCE Tolerance for merging or discarding nearby anchors
        %   DETACHTOLERANCE defines a threshold for how close anchors must be 
        %   before they are treated as the same anchor point. A value of zero 
        %   means no merging. Larger values cause anchors that lie within a 
        %   fraction of the bounding box range to be collapsed or removed.
        %
        %   DETACHTOLERANCE : double
        %
        %   See also update_candidate_space.
        DetachTolerance

        %INCLUDEANCHORINSHAPEDEFINITION Determine if anchors are included in shape definition
        %   INCLUDEANCHORINSHAPEDEFINITION is a logical flag that determines whether 
        %   anchor points are included in the shape definition.
        %
        %   INCLUDEANCHORINSHAPEDEFINITION : logical
        IncludeAnchorsInShapeDefinition

        %NORMALIZEGROWTHDIRECTION Determine if growth direction should be normalized
        %   When true, the growth direction is normalized to the design space.
        %
        %   NORMALIZEGROWTHDIRECTION : logical
        NormalizeGrowthDirection

        %GROWTHDIRECTIONTYPE Type of growth direction
        %   GROWTHDIRECTIONTYPE is a string that specifies the type of growth direction.
        %   It can be 'proportional' or 'isotropic'.
        %
        %   GROWTHDIRECTIONTYPE : string
        GrowthDirectionType

        %CHECKREDUNDANTRIMMINGGROWTH Determine if redundant trimming is checked
        %   When true, the redundant trimming is checked.
        %
        %   CHECKREDUNDANTRIMMINGGROWTH : logical
        CheckRedundantTrimmingGrowth

        %CHECKREDUNDANTRIMMINGUPDATE Determine if redundant trimming is checked
        %   When true, the redundant trimming is checked.
        %
        %   CHECKREDUNDANTRIMMINGUPDATE : logical
        CheckRedundantTrimmingUpdate

        %CHECKREDUNDANCYCADENCE Determine after how many calls the redundancy check is performed 
        %   When the number of calls to the candidate space redundancy check exceeds the value of
        %   CHECKREDUNDANCYCADENCE, the redundancy check is performed.
        %
        %   CHECKREDUNDANCYCADENCE : double
        CheckRedundancyCadence

        %PERFORMDETAILEDREDUNDANCYCHECK Determine if the detailed redundancy check is performed
        %   When true, when checking for redundancies, points are also projected to the
        %   boundaries of the corner box, and if none of them are inside the candidate
        %   space, then the point is considered redundant.
        %   This can remove many unnecessary anchors, but can also be quite expensive.
        %
        %   PERFORMDETAILEDREDUNDANCYCHECK : logical
        PerformDetailedRedundancyCheck

        %USEONLYOTHERANCHORSINREDUDANCYCHECK Determine if only other anchors are used in detailed redundancy check
        %   When true, only other anchors are used in the detailed redundancy check.
        %   Setting this to true can speed up computation time significantly, at the cost
        %   of wrongly assuming some redundancies.
        %
        %   USEONLYOTHERANCHORSINREDUDANCYCHECK : logical
        UseOnlyOtherAnchorsInRedundancyCheck

        %REDUNDANCYBATCHSIZE Determine the batch size for checking redundancy
        %   REDUNDANCYBATCHSIZE is the batch size used when checking if a plane
        %   defines a redundant region.
        %
        %   REDUNDANCYBATCHSIZE : integer
        RedundancyBatchSize

        %CHECKDUPLICATEPOINTSGROWTH Determine if duplicate points are checked
        %   When true, the duplicate points are checked.
        %
        %   CHECKDUPLICATEPOINTSGROWTH : logical
        CheckDuplicatePointsGrowth

        %CHECKDUPLICATEPOINTSUPDATE Determine if duplicate points are checked
        %   When true, the duplicate points are checked.
        %
        %   CHECKDUPLICATEPOINTSUPDATE : logical
        CheckDuplicatePointsUpdate

        %USE3DOPERATIONS Determine if 3D operations are used
        %   When true, check if designs are inside the candidate space or not using 3D
        %   vectorized operations. This may speed up computation time (not guaranteed),  
        %   at the cost of using more memory.
        %
        %   USE3DOPERATIONS : logical
        Use3DOperations

        %COMPUTEVARIANTSCORE Determine if the more complex variant of the score is used
        %   When true, the more complex variant of the score is used. This is used to
        %   compute the score of a design point.
        %
        %   COMPUTEVARIANTSCORE : logical
        ComputeVariantScore

        %MEASUREESTIMATIONFACTOR Factor to estimate the measure of the candidate space
        %   MEASUREESTIMATIONFACTOR is a factor that is used to estimate the measure of the 
        %   candidate space. This is used to determine the number of samples to use when 
        %   generating the candidate space.
        %
        %   MEASUREESTIMATIONFACTOR : double
        MeasureEstimationFactor
    end

    properties (SetAccess = protected, Dependent)
        %ISSHAPEDEFINITION Labels if sample points from definition contributes to shape
        %   ISSHAPEDEFINITION is a logical array where 'true' values indicate that that
        %   design point (in the respective row) from the definition sample actively 
        %   contributes to the shape of the candidate space. 
        %   In this case, these are the convex hull index points.
        %
        %   ISSHAPEDEFINITION : (nSample,1) logical
        %
        %   See also DesignSampleDefinition, IsInsideDefinition.
        IsShapeDefinition

        %MEASURE Size measure of the candidate space
        %   MEASURE is a value that works as the measure of the candidate space. This 
        %   may be its volume, or normalized volume relative to its design space, or
        %   some other metric.
        %   In this case, this is the sum of areas/volumes/... of the simplices as 
        %   computed.
        %
        %   MEASURE : double
        %
        %   See also DesignSampleDefinition, IsInsideDefinition, convhull, convhulln.   
        Measure

        %SAMPLINGBOX Bounding box of inside region used to help with sampling
        %   SAMPLINGBOX is a bounding box formed around the internal region of the
        %   candidate space. It can be used to facilitate trying to sample inside said
        %   space.
        %
        %   SAMPLINGBOX : (2,nDesignVariable) double
        %       - (1) : lower boundary of the design box
        %       - (2) : upper boundary of the design box
        %
        %   See also SamplingBoxSlack.
        SamplingBox
    end

    properties (Access = private)
        %REDUNDANCYCHECKCOUNT Count of calls to the candidate space redundancy check
        %   REDUNDANCYCHECKCOUNT is a counter that keeps track of the number of calls to the
        %   candidate space redundancy check.
        %
        %   REDUNDANCYCHECKCOUNT : double
        RedundancyCheckCount
    end
    
    methods
        function obj = CandidateSpaceCornerBoxRemoval(designSpaceLowerBound,designSpaceUpperBound,varargin)
        %CANDIDATESPACECONVEXHULL Constructor
        %   CANDIDATESPACECONVEXHULL is a constructor initializes an object of
        %   this class.
        %
        %   OBJ = CANDIDATESPACECONVEXHULL(DESIGNSPACELOWERBOUND,
        %   DESIGNSPACEUPPERBOUND) creates an object of the 
        %   CandidateSpaceConvexHull class and sets its design space boundaries
        %   to its input values DESIGNSPACELOWERBOUND and DESIGNSPACEUPPERBOUND.
        %   Other properties are set to empty.
        %
        %   OBJ = CANDIDATESPACECONVEXHULL(...,NAME,VALUE,...) also allows one to set
        %   specific options for the object. This can be 
        %       - 'SamplingBoxSlack' : where the boundaries of the sampling box 
        %       will be relative to the strictest bounding box and the most relaxed
        %       bounding box. A value of 0 means no slack and therefore the sampling
        %       box will be the most strict one possible, and 1 means the sampling
        %       box will be the most relaxed.
        %
        %   Inputs:
        %       - DESIGNSPACELOWERBOUND : (1,nDesignVariable) double
        %       - DESIGNSPACEUPPERBOUND : (1,nDesignVariable) double
        %       - 'SamplingBoxSlack' : double
        %
        %   Outputs:
        %       - OBJ : CandidateSpaceConvexHull
        %   
        %   See also convex_hull_plane.

            % parse inputs
            parser = inputParser;
            parser.addRequired('DesignSpaceLowerBound',@(x)isnumeric(x)&&(size(x,1)==1));
            parser.addRequired('DesignSpaceUpperBound',@(x)isnumeric(x)&&(size(x,1)==1));
            parser.addParameter('DetachTolerance',0);
            parser.addParameter('IncludeAnchorsInShapeDefinition',true,@islogical);
            parser.addParameter('NormalizeGrowthDirection',true,@islogical);
            parser.addParameter('GrowthDirectionType','proportional',@(x)any(strcmpi(x,{'proportional','isotropic','corner-direction','diagonal'})));
            parser.addParameter('CheckRedundantTrimmingGrowth',false,@islogical);
            parser.addParameter('CheckRedundantTrimmingUpdate',true,@islogical);
            parser.addParameter('CheckDuplicatePointsGrowth',false,@islogical);
            parser.addParameter('CheckDuplicatePointsUpdate',true,@islogical);
            parser.addParameter('CheckRedundancyCadence',10,@isnumeric);
            parser.addParameter('RedundancyBatchSize',64,@isnumeric);
            parser.addParameter('PerformDetailedRedundancyCheck',true,@islogical);
            parser.addParameter('UseOnlyOtherAnchorsInRedundancyCheck',true,@islogical);
            parser.addParameter('MeasureEstimationFactor',10);
            parser.addParameter('Use3DOperations',false,@islogical);
            parser.addParameter('ComputeVariantScore',false,@islogical);
            parser.parse(designSpaceLowerBound,designSpaceUpperBound,varargin{:});

            obj.DesignSpaceLowerBound = parser.Results.DesignSpaceLowerBound;
            obj.DesignSpaceUpperBound = parser.Results.DesignSpaceUpperBound;
            obj.DetachTolerance = parser.Results.DetachTolerance;
            obj.IncludeAnchorsInShapeDefinition = parser.Results.IncludeAnchorsInShapeDefinition;
            obj.NormalizeGrowthDirection = parser.Results.NormalizeGrowthDirection;
            obj.GrowthDirectionType = parser.Results.GrowthDirectionType;
            obj.CheckRedundantTrimmingGrowth = parser.Results.CheckRedundantTrimmingGrowth;
            obj.CheckRedundantTrimmingUpdate = parser.Results.CheckRedundantTrimmingUpdate;
            obj.CheckDuplicatePointsGrowth = parser.Results.CheckDuplicatePointsGrowth;
            obj.CheckDuplicatePointsUpdate = parser.Results.CheckDuplicatePointsUpdate;
            obj.CheckRedundancyCadence = parser.Results.CheckRedundancyCadence;
            obj.RedundancyBatchSize = parser.Results.RedundancyBatchSize;
            obj.UseOnlyOtherAnchorsInRedundancyCheck = parser.Results.UseOnlyOtherAnchorsInRedundancyCheck;
            obj.MeasureEstimationFactor = parser.Results.MeasureEstimationFactor;
            obj.Use3DOperations = parser.Results.Use3DOperations;
            obj.ComputeVariantScore = parser.Results.ComputeVariantScore;
            obj.PerformDetailedRedundancyCheck = parser.Results.PerformDetailedRedundancyCheck;

            obj.DesignSampleDefinition = [];
            obj.IsInsideDefinition = [];
            obj.AnchorPoint = [];
            obj.CornerDirection = [];
            obj.RedundancyCheckCount = 0;
        end
        
        function obj = generate_candidate_space(obj,designSample,trimmingInformation)
        %GENERATE_CANDIDATE_SPACE Define the candidate space from sample points
        %   GENERATE_CANDIDATE_SPACE uses sample points and trimming information
        %   to determine which corners should be removed. The inside definition 
        %   is then updated accordingly.
        %
        %   OBJ = OBJ.GENERATE_CANDIDATE_SPACE(DESIGNSAMPLE,TRIMMINGINFORMATION)
        %   sets DesignSampleDefinition to DESIGNSAMPLE, and if 
        %   trimmingInformation is provided, populates AnchorPoint and
        %   CornerDirection. 
        %
        %   Inputs:
        %       - OBJ : CandidateSpaceCornerBoxRemoval
        %       - DESIGNSAMPLE : (nSample,nDesignVariable) double
        %       - TRIMMINGINFORMATION : (nCorner,1) struct
        %           -- Anchor : (1,nDimension) double
        %           -- CornerDirection : (1,nDimension) logical
        %
        %   Outputs:
        %       - OBJ : CandidateSpaceCornerBoxRemoval
        %
        %   See also AnchorPoint, CornerDirection, is_in_candidate_space.

            obj.DesignSampleDefinition = designSample;

            if(~isempty(trimmingInformation))
                obj.AnchorPoint = vertcat(trimmingInformation.Anchor);
                obj.CornerDirection = vertcat(trimmingInformation.CornerDirection);
            end
            obj.IsInsideDefinition = obj.is_in_candidate_space(designSample,false);
        end

        function obj = update_candidate_space(obj,designSample,~,trimmingInformation)
        %UPDATE_CANDIDATE_SPACE Incorporate new corner anchors or samples
        %   UPDATE_CANDIDATE_SPACE merges existing anchors with new ones from
        %   trimmingInformation, checks for redundant anchors, and merges new 
        %   sample points. The inside definition is recalculated.
        %
        %   OBJ = OBJ.UPDATE_CANDIDATE_SPACE(DESIGNSAMPLE,ISINSIDE,TRIMMINGINFORMATION)
        %   updates the internal state of the object by appending anchors and 
        %   corner directions from TRIMMINGINFORMATION. It also checks for
        %   redundant anchors and merges them if needed. 
        %
        %   Inputs:
        %       - OBJ : CandidateSpaceCornerBoxRemoval
        %       - DESIGNSAMPLE : (nSample,nDesignVariable) double
        %       - ISINSIDE : (nSample,1) logical
        %       - TRIMMINGINFORMATION : struct
        %
        %   Outputs:
        %       - OBJ : CandidateSpaceCornerBoxRemoval
        %
        %   See also generate_candidate_space, AnchorPoint, CornerDirection.

            if(isempty(obj.DesignSampleDefinition) || isempty(obj.AnchorPoint))
                obj = obj.generate_candidate_space(designSample,trimmingInformation);
                return;
            end

            if(~isempty(trimmingInformation))
                anchorPointNew = vertcat(trimmingInformation.Anchor);
                cornerDirectionNew = vertcat(trimmingInformation.CornerDirection);
                
                obj.AnchorPoint = [obj.AnchorPoint;anchorPointNew];
                obj.CornerDirection = [obj.CornerDirection;cornerDirectionNew];
    
                % verify if there are any redundant anchor points
                % -> region removed includes a different anchor with same corner direction
                if(obj.CheckRedundantTrimmingUpdate)
                    obj = obj.remove_redundant_anchors();
                end

                % check for detachments
                if(obj.DetachTolerance>0)
                    obj = obj.move_anchors_for_detachment();
                end
            end

            % keep samples in inside/outside
            [~,iLowerBoundaryAll] = min(obj.DesignSampleDefinition,[],1);
            [~,iUpperBoundaryAll] = max(obj.DesignSampleDefinition,[],1);

            insideSample = obj.DesignSampleDefinition(obj.IsInsideDefinition,:);
            [~,iLowerBoundaryInside] = min(insideSample,[],1);
            [~,iUpperBoundaryInside] = max(insideSample,[],1);
            iBoundaryInside = convert_index_base(obj.IsInsideDefinition,[iLowerBoundaryInside,iUpperBoundaryInside]','backward');

            iMaintain = unique([iLowerBoundaryAll';iUpperBoundaryAll';iBoundaryInside],'rows');
            obj.DesignSampleDefinition = [...
                obj.DesignSampleDefinition(iMaintain,:);...
                designSample;...
                obj.AnchorPoint];
            if(obj.CheckDuplicatePointsUpdate)
                obj.DesignSampleDefinition = unique(obj.DesignSampleDefinition,'rows');
            end
            obj.IsInsideDefinition = obj.is_in_candidate_space(obj.DesignSampleDefinition,false);
        end
        
        function obj = expand_candidate_space(obj,growthRate)
        %EXPAND_CANDIDATE_SPACE Expansion of candidate space by given factor
        %   EXPAND_CANDIDATE_SPACE will grow the region considered inside the current 
        %   candidate space by the factor given. Said growth is done in a fixed rate 
        %   defined by the input relative to the design space.
        %   This is done by finding the center of the convex hull and then making all 
        %   inside designs move opposite to that direction. 
        %
        %   OBJ = OBJ.EXPAND_CANDIDATE_SPACE(GROWTHRATE) will growth the candidate space 
        %   defined in OBJ by a factor of GROWTHRATE. This is an isotropic expansion of 
        %   the candidate space by a factor of the growth rate times the size of the 
        %   design space.
        %
        %   Inputs:
        %       - OBJ : CandidateSpaceConvexHull
        %       - GROWTHRATE : double
        %   
        %   Outputs:
        %       - OBJ : CandidateSpaceConvexHull
        %   
        %   See also generate_candidate_space, is_in_candidate_space.

            designSpaceFactor = obj.DesignSpaceUpperBound - obj.DesignSpaceLowerBound;
            if(obj.NormalizeGrowthDirection)
                designSpaceNormalization = designSpaceFactor;
            else
                designSpaceNormalization = 1;
            end

            % growth for anchors
            if(~isempty(obj.AnchorPoint))
                insideSampleNormalized = obj.DesignSampleDefinition(obj.IsInsideDefinition,:)./designSpaceNormalization;

                nAnchor = size(obj.AnchorPoint,1);
                nDimension = size(obj.DesignSpaceLowerBound,2);
                directionGrowth = nan(nAnchor,nDimension);

                % pre-normalize
                anchorPointNormalized = obj.AnchorPoint./designSpaceNormalization;

                for i=1:nAnchor
                    % simpler methods
                    if(strcmpi(obj.GrowthDirectionType,'diagonal'))
                        directionGrowth(i,:) = ones(1,nDimension);
                        continue;
                    elseif(strcmpi(obj.GrowthDirectionType,'corner-direction'))
                        directionGrowth(i,obj.CornerDirection(i,:)) = obj.DesignSpaceUpperBound(obj.CornerDirection(i,:)) - obj.AnchorPoint(i,obj.CornerDirection(i,:));
                        directionGrowth(i,~obj.CornerDirection(i,:)) = obj.AnchorPoint(i,~obj.CornerDirection(i,:)) - obj.DesignSpaceLowerBound(~obj.CornerDirection(i,:));
                        continue;
                    end

                    % distances to anchor (positive -> inside) with corner-direction flips
                    distanceToAnchor = insideSampleNormalized - anchorPointNormalized(i,:);
                    distanceToAnchor(:,obj.CornerDirection(i,:)) = -distanceToAnchor(:,obj.CornerDirection(i,:));

                    if(strcmpi(obj.GrowthDirectionType,'proportional'))
                        [~,iDimension] = max(distanceToAnchor,[],2);
                        directionGrowth(i,:) = accumarray(iDimension,1,[nDimension,1])';
                    elseif(strcmpi(obj.GrowthDirectionType,'isotropic'))
                        directionGrowth(i,:) = any(distanceToAnchor<0,1);
                    else
                        error('Invalid growth direction type');
                    end
                end

                % apply sign per corner orientation and normalize rows safely
                directionGrowth(~obj.CornerDirection) = -directionGrowth(~obj.CornerDirection);
                directionGrowth = directionGrowth./vecnorm(directionGrowth,2,2);

                anchorPointNew = obj.AnchorPoint + growthRate.*designSpaceFactor.*directionGrowth;
                anchorPointNew = min(max(anchorPointNew,obj.DesignSpaceLowerBound),obj.DesignSpaceUpperBound);

                % don't include anchors that were moved to the boundary corners
                isAnchorInLowerBoundary = (anchorPointNew<=obj.DesignSpaceLowerBound);
                isAnchorInUpperBoundary = (anchorPointNew>=obj.DesignSpaceUpperBound);
                isAnchorInCorner = all(isAnchorInLowerBoundary|isAnchorInUpperBoundary,2);

                obj.AnchorPoint = anchorPointNew(~isAnchorInCorner,:);
                obj.CornerDirection = obj.CornerDirection(~isAnchorInCorner,:);

                if(obj.CheckRedundantTrimmingGrowth)
                    obj = obj.remove_redundant_anchors();
                end

                % check for detachments
                if(obj.DetachTolerance>0)
                    obj = obj.move_anchors_for_detachment();
                end
            end

            center = mean(obj.DesignSampleDefinition(obj.IsInsideDefinition,:),1);
            distanceToCenter = (obj.DesignSampleDefinition - center)./designSpaceNormalization;
            normalizedDirectionGrowth = distanceToCenter./vecnorm(distanceToCenter,2,2);

            % compute distance to design space boundaries
            growthDirection = designSpaceFactor.*normalizedDirectionGrowth;
            distanceUpperBound = obj.DesignSpaceUpperBound - obj.DesignSampleDefinition;
            distanceLowerBound = obj.DesignSampleDefinition - obj.DesignSpaceLowerBound;

            % positive direction - away from center
            maskPositive = (growthDirection>0);
            positiveDistance = distanceUpperBound.*maskPositive + distanceLowerBound.*(~maskPositive);
            maxPositiveStep = min(positiveDistance./abs(growthDirection),[],2);
            designSampleNewPositive = obj.DesignSampleDefinition + min(growthRate,maxPositiveStep).*growthDirection;

            % negative direction - towards center
            maskNegative = (-growthDirection>0);
            negativeDistance = distanceUpperBound.*maskNegative + distanceLowerBound.*(~maskNegative);
            maxNegativeStep = min(negativeDistance./abs(growthDirection),[],2);
            designSampleNewNegative = obj.DesignSampleDefinition + min(growthRate,maxNegativeStep).*(-growthDirection);

            % keep samples in inside/outside
            [~,iLowerBoundaryAll] = min(obj.DesignSampleDefinition,[],1);
            [~,iUpperBoundaryAll] = max(obj.DesignSampleDefinition,[],1);

            insideSample = obj.DesignSampleDefinition(obj.IsInsideDefinition,:);
            [~,iLowerBoundaryInside] = min(insideSample,[],1);
            [~,iUpperBoundaryInside] = max(insideSample,[],1);
            iBoundaryInside = convert_index_base(obj.IsInsideDefinition,[iLowerBoundaryInside,iUpperBoundaryInside]','backward');

            iMaintain = unique([iLowerBoundaryAll';iUpperBoundaryAll';iBoundaryInside],'rows');

            % concatenate anchors to design sample definition
            obj.DesignSampleDefinition = [...
                obj.DesignSampleDefinition(iMaintain,:);...
                designSampleNewPositive;...
                designSampleNewNegative;...
                obj.AnchorPoint];
            if(obj.CheckDuplicatePointsGrowth)
                obj.DesignSampleDefinition = unique(obj.DesignSampleDefinition,'rows');
            end
            obj.IsInsideDefinition = obj.is_in_candidate_space(obj.DesignSampleDefinition,false);
        end
        
        function [isInside, score] = is_in_candidate_space(obj,designSample,includeBoundingBox)
        %IS_IN_CANDIDATE_SPACE Verification if given design samples are inside
        %   IS_IN_CANDIDATE_SPACE uses the currently defined candidate space to 
        %   determine if given design sample points are inside or outside the candidate 
        %   space.
        %
        %   ISINSIDE = OBJ.IS_IN_CANDIDATE_SPACE(DESIGNSAMPLE) receives the design
        %   samples in DESIGNSAMPLE and returns whether or not they are inside the 
        %   candidate space in ISINSIDE. For ISINSIDE values of 'true', it means the 
        %   respective design is inside the candidate space, while 'false' means it is 
        %   outside.
        %
        %   [ISINSIDE,SCORE] = OBJ.IS_IN_CANDIDATE_SPACE(...) also returns a SCORE value
        %   for each sample point; negative values of SCORE indicate the design sample 
        %   is inside the candidate space, and positive values indicate it is outside. 
        %   Designs with lower/higher SCORE are further from the boundary, with 0 
        %   representing that they are exactly at the boundary.
        %
        %   Inputs:
        %       - OBJ : CandidateSpaceConvexHull
        %       - DESIGNSAMPLE : (nSample,nDesignVariable) double
        %   
        %   Outputs:
        %       - ISINSIDE : (nSample,1) logical
        %       - SCORE : (nSample,1) double
        %   
        %   See also is_in_convex_hull_with_plane.

            nSample = size(designSample,1);
            if(isempty(obj.DesignSampleDefinition))
                isInside = true(nSample,1);
                score = zeros(nSample,1);
                return;
            elseif(isempty(obj.AnchorPoint))
                boundingBox = design_bounding_box(obj.DesignSampleDefinition);
                [isInside,score] = is_in_design_box(designSample,boundingBox);
                return;
            end

            % determine sign based on corner direction
            nAnchor = size(obj.AnchorPoint,1);
            nDimension = size(obj.AnchorPoint,2);

            if(obj.Use3DOperations)
                signVector = (~obj.CornerDirection) - (obj.CornerDirection);

                % vectorized operation
                distanceToAnchor = (designSample - reshape(obj.AnchorPoint',1,nDimension,nAnchor)).*reshape(signVector',1,nDimension,nAnchor);
                distanceMaximumPerAnchor = reshape(max(distanceToAnchor,[],2),nSample,nAnchor);
            else
                signMatrix = ones(nAnchor,nDimension);
                signMatrix(obj.CornerDirection) = -1;

                % find the maximum distance to all anchors, see which dimension is 
                % the closest for each anchor
                distanceMaximumPerAnchor = -inf(nSample,nAnchor);
                for iDimension = 1:nDimension
                    distanceDimension = (designSample(:,iDimension) - obj.AnchorPoint(:,iDimension)').*(signMatrix(:,iDimension)'); % (nSample,nAnchor)
                    distanceMaximumPerAnchor = max(distanceMaximumPerAnchor, distanceDimension);
                end
            end
            if(obj.ComputeVariantScore)
                [isInside,score] = design_deficit_to_label_score(-distanceMaximumPerAnchor);
            else
                isInside = all(distanceMaximumPerAnchor>=0,2);
                score = max(-distanceMaximumPerAnchor,[],2);
            end

            % check if it's inside the bounding box
            if(nargin<3 || includeBoundingBox)
                boundingBox = design_bounding_box(obj.DesignSampleDefinition,obj.IsInsideDefinition);
                boundingBox = min(max(boundingBox,obj.DesignSpaceLowerBound),obj.DesignSpaceUpperBound);
            else
                boundingBox = [obj.DesignSpaceLowerBound;obj.DesignSpaceUpperBound];
            end
            [isInsideBounding,scoreBounding] = is_in_design_box(designSample,boundingBox);
            isInside(~isInsideBounding) = false;
            score = max(score,scoreBounding);
        end

        function isShapeDefinition = get.IsShapeDefinition(obj)
            if(isempty(obj.DesignSampleDefinition))
                isShapeDefinition = [];
            else
                [~,iLowerBoundaryAll] = min(obj.DesignSampleDefinition,[],1);
                [~,iUpperBoundaryAll] = max(obj.DesignSampleDefinition,[],1);

                isInsideDefinition = obj.IsInsideDefinition;
                [~,iLowerBoundaryInside] = min(obj.DesignSampleDefinition(isInsideDefinition,:),[],1);
                [~,iUpperBoundaryInside] = max(obj.DesignSampleDefinition(isInsideDefinition,:),[],1);
                iBoundaryInside = convert_index_base(isInsideDefinition,[iLowerBoundaryInside,iUpperBoundaryInside]','backward');

                isShapeDefinition = false(size(obj.DesignSampleDefinition,1),1);
                isShapeDefinition([iLowerBoundaryAll,iUpperBoundaryAll,iBoundaryInside']) = true;
                
                if(~isempty(obj.AnchorPoint) && obj.IncludeAnchorsInShapeDefinition)
                    isShapeDefinition(ismember(obj.DesignSampleDefinition,obj.AnchorPoint,'rows')) = true;
                end
            end
        end

        function samplingBox = get.SamplingBox(obj)
            samplingBox = design_bounding_box(...
                obj.DesignSampleDefinition,obj.IsInsideDefinition);
        end

        function volume = get.Measure(obj)
            nSample = obj.MeasureEstimationFactor*size(obj.DesignSampleDefinition,1);
            samplingBox = obj.SamplingBox;
            
            volumeSample = sampling_random(samplingBox,nSample);
            isInside = obj.is_in_candidate_space(volumeSample);
            volumeFactor = sum(isInside) / size(isInside,1);
            volume = volumeFactor * prod(samplingBox(2,:) - samplingBox(1,:));
        end
    end

    methods (Access = private)
        function obj = remove_redundant_anchors(obj)
            % Fast redundancy removal for corner anchors. This implements two
            % stages:
            %   (1) Vectorized dominance check among anchors with identical
            %       corner-directions.
            %   (2) Batched detailed projection check to minimize expensive
            %       candidate-space evaluations.

            nAnchor = size(obj.AnchorPoint,1);
            if(nAnchor<=1)
                return;
            end

            nDimension = size(obj.AnchorPoint,2);

            % --- Stage 1: Same-direction vectorized dominance check ---
            % Precompute sign matrix for all anchors: +1 for lower, -1 for upper
            signMatrix = ones(nAnchor,nDimension);
            signMatrix(obj.CornerDirection) = -1;

            isRedundantAnchor = false(nAnchor,1);
            % Group anchors by identical corner-direction for efficient checks
            [~,~,groupIndex] = unique(obj.CornerDirection,'rows');
            nGroup = max(groupIndex);
            for iGroup = 1:nGroup
                iAnchorGroup = find(groupIndex==iGroup);
                groupSize = numel(iAnchorGroup);
                if(groupSize<=1)
                    continue;
                end

                % Apply sign flip per group (all equal within group)
                anchorCurrentGroupSigned = obj.AnchorPoint(iAnchorGroup,:) .* signMatrix(iAnchorGroup,:);

                % Pairwise strict dominance: Xs(p,:) > Xs(q,:) for all dims
                isGreaterAll = true(groupSize,groupSize);
                for iDimension = 1:nDimension
                    isGreaterAll = isGreaterAll & (anchorCurrentGroupSigned(:,iDimension) > (anchorCurrentGroupSigned(:,iDimension)'));
                end

                % Column q is dominated if any row p strictly greater in all dims
                isDominatedInGroup = any(isGreaterAll,1)';
                if(any(isDominatedInGroup))
                    isRedundantAnchor(iAnchorGroup) = isDominatedInGroup;
                end
            end

            % Remove trivially redundant anchors before detailed checks
            if(any(isRedundantAnchor))
                obj.AnchorPoint(isRedundantAnchor,:) = [];
                obj.CornerDirection(isRedundantAnchor,:) = [];
                nAnchor = size(obj.AnchorPoint,1);
                if(nAnchor<=1)
                    return;
                end
            end

            % only go to stage 2 after the count
            obj.RedundancyCheckCount = obj.RedundancyCheckCount + 1;
            if(obj.RedundancyCheckCount < obj.CheckRedundancyCadence)
                return;
            end
            obj.RedundancyCheckCount = 0;

            % --- Stage 2: Detailed projection redundancy check (batched) ---
            % Project points to each anchor's corner and test if any projected
            % points remain inside. If none remain inside, the anchor is redundant.
            if(obj.PerformDetailedRedundancyCheck && nAnchor>1)
                % Choose points to project
                if(obj.UseOnlyOtherAnchorsInRedundancyCheck)
                    pointsToMove = obj.AnchorPoint;
                else
                    pointsToMove = obj.DesignSampleDefinition;
                end

                % Recompute sign matrix for the reduced set
                signMatrix = ones(nAnchor,nDimension);
                signMatrix(obj.CornerDirection) = -1;

                isRedundantAnchor = false(nAnchor,1);

                % Batch anchors to limit memory and reduce the number of
                % calls to the candidate-space evaluation.
                batchSizeMax = min(obj.RedundancyBatchSize,nAnchor);
                for iStart = 1:batchSizeMax:nAnchor
                    iEnd = min(iStart+batchSizeMax-1,nAnchor);
                    iBatchAnchor = iStart:iEnd;
                    batchSize = numel(iBatchAnchor);

                    candidatePoint = cell(batchSize,1);
                    nMovedPointPerAnchor = zeros(batchSize,1);

                    for iBatchElement = 1:batchSize
                        iAnchor = iBatchAnchor(iBatchElement);
                        signVector = signMatrix(iAnchor,:);
                        distanceToAnchor = (pointsToMove - obj.AnchorPoint(iAnchor,:)).*signVector;

                        % Shift only if the point does not collapse to the
                        % same anchor corner or the opposite corner
                        isCollapsing = all(distanceToAnchor<0,2) | all(distanceToAnchor>0,2);
                        if(any(~isCollapsing))
                            shiftAmount = -max(distanceToAnchor(~isCollapsing,:),0).*signVector;
                            candidatePointAnchor = pointsToMove(~isCollapsing,:) + shiftAmount;
                            candidatePointAnchor = min(max(candidatePointAnchor,obj.DesignSpaceLowerBound),obj.DesignSpaceUpperBound);
                            candidatePoint{iBatchElement} = candidatePointAnchor;
                            nMovedPointPerAnchor(iBatchElement) = size(candidatePointAnchor,1);
                        else
                            nMovedPointPerAnchor(iBatchElement) = 0;
                        end
                    end

                    hasPointMoved = (nMovedPointPerAnchor>0);
                    if(any(hasPointMoved))
                        candidatePointAll = vertcat(candidatePoint{hasPointMoved});
                        isInsideProjected = obj.is_in_candidate_space(candidatePointAll,false);

                        % Map results back to anchors
                        iStartCurrentAnchor = 1;
                        for iBatchElement = 1:batchSize
                            if(~hasPointMoved(iBatchElement))
                                continue;
                            end

                            iEndCurrentAnchor = iStartCurrentAnchor + nMovedPointPerAnchor(iBatchElement) - 1;
                            if(~any(isInsideProjected(iStartCurrentAnchor:iEndCurrentAnchor)))
                                isRedundantAnchor(iBatchAnchor(iBatchElement)) = true;
                            end

                            iStartCurrentAnchor = iEndCurrentAnchor + 1;
                        end
                    end
                end

                if(any(isRedundantAnchor))
                    obj.AnchorPoint(isRedundantAnchor,:) = [];
                    obj.CornerDirection(isRedundantAnchor,:) = [];
                end
            end
        end

        function obj = move_anchors_for_detachment(obj)
            nAnchor = size(obj.AnchorPoint,1);
                    
            lowerBound = min(obj.DesignSampleDefinition(obj.IsInsideDefinition,:),[],1);
            upperBound = max(obj.DesignSampleDefinition(obj.IsInsideDefinition,:),[],1);
            allowedSlack = obj.DetachTolerance.*(upperBound - lowerBound);

            for i=1:nAnchor
                distanceToAnchor = obj.AnchorPoint - obj.AnchorPoint(i,:);
                distanceToAnchor(:,obj.CornerDirection(i,:)) = -distanceToAnchor(:,obj.CornerDirection(i,:));

                [maximumSlack,iDimension] = max(distanceToAnchor,[],2);
                
                shouldCollapse = (abs(maximumSlack)<=allowedSlack(:,iDimension)');
                dimensionsToCollapse = (distanceToAnchor>=0) & (distanceToAnchor<=allowedSlack) & (obj.CornerDirection~=obj.CornerDirection(i,:));
                currentAnchor = repmat(obj.AnchorPoint(i,:),sum(shouldCollapse),1);
                obj.AnchorPoint(shouldCollapse & dimensionsToCollapse) = currentAnchor(dimensionsToCollapse(shouldCollapse,:));
            end
        end
    end
end