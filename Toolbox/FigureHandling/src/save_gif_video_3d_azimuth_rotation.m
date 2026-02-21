function save_gif_video_3d_azimuth_rotation(figureHandle,filename,varargin)
    parser = inputParser;
    parser.addOptional('InitialAzimuth',[]);
    parser.addOptional('Elevation',[]);
    parser.addParameter('CameraPosition',[]);
    parser.addParameter('Duration',5);
    parser.addParameter('FramesPerSecond',30);
    parser.addParameter('SaveGif',true);
    parser.addParameter('ImwriteOptions',{});
    parser.addParameter('SaveVideo',true);
    parser.addParameter('VideoWriterProfile','Motion JPEG 2000');
    parser.addParameter('VideoWriterOptions',{'LosslessCompression',true});
    parser.parse(varargin{:});
    options = parser.Results;

    [currentAzimuth,currentElevation] = view;

    initialAzimuth = options.InitialAzimuth;
    if(isempty(initialAzimuth))
        initialAzimuth = currentAzimuth;
    end

    elevation = options.Elevation;
    if(isempty(elevation))
        elevation = currentElevation;
    end

    totalFrame = options.FramesPerSecond*options.Duration;
    azimuthVideo = mod(initialAzimuth + linspace(0,360,totalFrame),360);
    frameDelay = 1/options.FramesPerSecond;

    if(~isempty(options.CameraPosition))
        campos(options.CameraPosition);
    end

    figure(figureHandle);
    set(figureHandle, 'MenuBar', 'none');
    set(figureHandle, 'ToolBar', 'none');

    for iFrame = 1:totalFrame
        view(azimuthVideo(iFrame),elevation);

        if(options.SaveGif)
            [A,map] = rgb2ind(frame2im(getframe(gcf)),256);
            if(iFrame==1)
                imwrite(A,map,...
                    [filename,'.gif'],'gif',...
                    'LoopCount',inf,...
                    'DelayTime',frameDelay,...
                    options.ImwriteOptions{:});
            else
                imwrite(A,map,...
                    [filename,'.gif'],'gif',...
                    'WriteMode','append', ...
                    'DelayTime',frameDelay,...
                    options.ImwriteOptions{:});
            end
        end

        if(options.SaveVideo)
            if(iFrame==1)
                % initialize video object + process options
                videoHandle = VideoWriter(filename,options.VideoWriterProfile);
                for i=1:2:length(options.VideoWriterOptions)
                    videoHandle.(options.VideoWriterOptions{i}) = options.VideoWriterOptions{i+1};
                end
                open(videoHandle);
            end

            currentFrame = getframe(gcf);
            writeVideo(videoHandle,currentFrame);

            if(iFrame==totalFrame)
                close(videoHandle);
            end
        end
    end

    % reset menu/tool bars
    set(figureHandle, 'MenuBar', 'figure');
    set(figureHandle, 'ToolBar', 'auto');
end