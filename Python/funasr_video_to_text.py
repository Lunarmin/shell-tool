import os
from funasr import AutoModel
from moviepy.editor import VideoFileClip

# ================= 配置区域 =================
# 在这里填入你的 MP4 文件路径 (支持绝对路径或相对路径)
video_path = "xxxx.mp4"  # 例如: "C:\\Users\\Admin\\Videos\\meeting.mp4" 或 "./my_video.mp4"

# 临时音频文件保存路径
audio_path = "temp_audio.wav"
# ===========================================

def extract_audio(video_file, output_audio):
    """使用 moviepy 从视频中提取音频"""
    print(f"🎬 正在从视频提取音频: {video_file} ...")
    try:
        clip = VideoFileClip(video_file)
        clip.audio.write_audiofile(output_audio, logger=None) # logger=None 屏蔽多余日志
        clip.close()
        print(f"✅ 音频提取成功: {output_audio}")
        return True
    except Exception as e:
        print(f"❌ 音频提取失败: {e}")
        return False

def transcribe_audio(audio_file):
    """使用 FunASR (Paraformer) 进行语音识别"""
    print("🤖 正在加载 FunASR 模型 (首次运行会自动下载模型，请耐心等待)...")
    
    # 初始化模型
    # device="cpu" 强制使用 CPU
    # model="paraformer-zh" 是中文识别效果最好的通用模型
    model = AutoModel(model="paraformer-zh", device="cpu", vad_model="fsmn-vad", punc_model="ct-punc")
    
    print("🎙️ 开始识别语音...")
    
    # 执行识别
    # res 是一个列表，包含识别结果
    res = model.generate(input=audio_file)
    
    return res

def main():
    if not os.path.exists(video_path):
        print(f"❌ 错误：找不到文件 '{video_path}'，请检查路径是否正确。")
        return

    # 1. 提取音频
    if not extract_audio(video_path, audio_path):
        return

    # 2. 语音识别
    try:
        result = transcribe_audio(audio_path)
        
        print("\n" + "="*30)
        print("📝 识别结果:")
        print("="*30)
        
        # 解析结果 (Paraformer 返回的结构可能包含 text 字段)
        full_text = ""
        if isinstance(result, list):
            for item in result:
                if isinstance(item, dict) and 'text' in item:
                    text = item['text']
                    print(text) # 逐句打印
                    full_text += text + "\n"
                elif isinstance(item, str):
                    # 某些旧版本或直接返回字符串
                    print(item)
                    full_text += item + "\n"
        elif isinstance(result, dict) and 'text' in result:
            full_text = result['text']
            print(full_text)
            
        print("="*30)
        
        # 保存结果到 txt 文件
        output_txt = video_path.rsplit('.', 1)[0] + ".txt"
        with open(output_txt, "w", encoding="utf-8") as f:
            f.write(full_text)
        print(f"💾 文字已保存到: {output_txt}")
        
    except Exception as e:
        print(f"❌ 识别过程中出错: {e}")
    
    finally:
        # 清理临时音频文件
        if os.path.exists(audio_path):
            os.remove(audio_path)
            print("🧹 已清理临时音频文件。")

if __name__ == "__main__":
    main()
