img = imread('飞行器视觉汇报课题20241020.jpg'); % 替换成你的图像路径
lbp_feature_with_output(img); % 生成并保存PDF输出


function lbp_feature_with_output(inputImage)
    % 检查输入图像是否为灰度图像
    if size(inputImage, 3) == 3
        inputImage = rgb2gray(inputImage); % 转换为灰度图像
    end

    % 获取图像的大小
    [rows, cols] = size(inputImage);

    % 初始化LBP图像
    lbpImage = zeros(rows, cols);
    lbpValues = zeros(rows-2, cols-2); % 存储LBP值以便输出

    % 处理每一个像素（忽略图像边界）
    for i = 2:rows-1
        for j = 2:cols-1
            % 提取3x3邻域
            neighborhood = inputImage(i-1:i+1, j-1:j+1);

            % 中心像素值
            centerPixel = neighborhood(2, 2);

            % 初始化LBP编码
            lbpCode = 0;
            
            % 遍历邻域像素，计算LBP二进制模式
            lbpCode = lbpCode + (neighborhood(1, 1) >= centerPixel) * 2^7;
            lbpCode = lbpCode + (neighborhood(1, 2) >= centerPixel) * 2^6;
            lbpCode = lbpCode + (neighborhood(1, 3) >= centerPixel) * 2^5;
            lbpCode = lbpCode + (neighborhood(2, 3) >= centerPixel) * 2^4;
            lbpCode = lbpCode + (neighborhood(3, 3) >= centerPixel) * 2^3;
            lbpCode = lbpCode + (neighborhood(3, 2) >= centerPixel) * 2^2;
            lbpCode = lbpCode + (neighborhood(3, 1) >= centerPixel) * 2^1;
            lbpCode = lbpCode + (neighborhood(2, 1) >= centerPixel) * 2^0;
            
            % 将LBP编码赋值到LBP图像和lbpValues数组中
            lbpImage(i, j) = lbpCode;
            lbpValues(i-1, j-1) = lbpCode; % 存储LBP值
        end
    end

    % 显示原始图像和LBP特征图
    figure;
    subplot(1, 2, 1); imshow(inputImage); title('原始灰度图像');
    subplot(1, 2, 2); imshow(uint8(lbpImage)); title('LBP特征图');

    % 保存LBP特征图像为临时文件
    lbpImageFilename = 'lbp_feature_image.png';
    saveas(gcf, lbpImageFilename);

    % 输出LBP数值到文本文件
    lbpValuesFilename = 'lbp_values.txt';
    writematrix(lbpValues, lbpValuesFilename);

    % 合并图像和文本文件为PDF
    outputPDF = 'LBP_Feature_Output.pdf';
    import mlreportgen.report.*
    import mlreportgen.dom.*

    % 创建PDF报告
    report = Report(outputPDF, 'pdf');
    add(report, TitlePage('Title', 'LBP Feature Extraction', 'Author', 'Generated by MATLAB'));

    % 添加图像和LBP数值内容
    chapter = Chapter('Title', 'LBP Feature and Values');
    imageObj = Image(lbpImageFilename);
    imageObj.Width = '5in';
    imageObj.Height = '4in';
    add(chapter, imageObj);

    % 添加LBP数值文本
    lbpText = fileread(lbpValuesFilename); % 读取LBP值文本内容
    textObj = Text(lbpText);
    add(chapter, textObj);

    % 将章节添加到报告
    add(report, chapter);

    % 关闭并生成PDF
    close(report);
    rptview(outputPDF);
end
