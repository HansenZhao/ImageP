classdef ImageContainer < handle
    
    properties
        nwidth;
        nheight;
        nframe;
        pixelList;
    end

    properties (Access=private)
        raw;
    end
    
    methods
        function obj = ImageContainer(varargin)
         if isempty(varargin)
            obj.raw = ImageContainer.readV();
         else
            if(length(size(varargin{1})) == 3)
                obj.raw = varargin{1};
            else if(length(size(varargin{1})) == 4)
                [a,b,~,nf] = size(varargin{1});
                obj.raw = zeros(a,b,nf,'uint8');
                for m = 1:nf
                    obj.raw(:,:,m)=varargin{1}(:,:,1,m);
                end
                else
                    error('Cannot solve input image stack');
                end
            end
         end
         [obj.nheight,obj.nwidth,obj.nframe] = size(obj.raw);
         obj.pixelList = ImageContainer.mat2list(obj.raw,obj.nwidth,obj.nheight,obj.nframe);
        end

        function subMatrix = getSubImage(obj,varargin)
            if isempty(varargin)
                subMatrix = obj.raw;
            else
                mrect = varargin{1};
                x = floor(mrect(1));
                y = floor(mrect(2));
                w = round(mrect(3));
                h = round(mrect(4));
                subMatrix = obj.raw(x:(x+w),y:(y+h),:);
            end
        end

        function zprof = getZMean(obj,varargin)
            if isempty(varargin)
                matrix = obj.raw;
            else
                matrix = obj.getSubImage(varargin{1});
            end
            zprof = mean(mean(matrix,1),2);
            zprof = zprof(:,:);
        end
        
         function zprof = getZMax(obj,varargin)
            if isempty(varargin)
                matrix = obj.raw;
            else
                matrix = obj.getSubImage(varargin{1});
            end
            zprof = max(max(matrix,[],1),[],2);
            zprof = zprof(:,:);
        end

        function rt = selectRect(obj)
            figure;
            a = obj.raw(:,:,1);
            imshow(a./max(a(:)));
            rt = getrect();
        end
        
        function normBy(obj,bg)
            k = zeros(1,1,obj.nframe);
            k(1,1,:) = bg;
            obj.raw = obj.raw./repmat(k,[obj.nheight,obj.nwidth,1]);
        end
    end

    methods (Access=private)
    end

    methods (Static)
        function imRaw = readV()
            [fileName,filePath,index] = uigetfile();
            if index
                v = VideoReader(strcat(filePath,fileName));
                vf = read(v);
                vf = double(vf);
                [a,b,~,nf] = size(vf);
                imRaw = zeros(a,b,nf);
                for m = 1:nf
                    imRaw(:,:,m)=vf(:,:,1,m);
                end
            end
        end
        
        function v = imMax(mat)
            v = max(mat(:));
        end
        
        function list = mat2list(mat,w,h,nf)
            num = w*h;
            list = zeros(num,nf);
            x=0;
            y=0;
            for m = 1:1:num
                [x,y]=ImageContainer.index2xy(m,w);
                list(m,:)=mat(x,y,:);
            end
        end
        
        function mat = array2mat(ar,w,h)
            mat = reshape(ar,[h,w]);
            mat = mat';
        end
        function [x,y] = index2xy(index,w)
            x = ceil(index/w);
            y = mod(index,w);
            if y == 0
                y = w;
            end
        end
    end 
end

