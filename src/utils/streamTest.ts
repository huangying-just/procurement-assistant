// 测试流式输出功能的工具函数
export const testStreamingResponse = async () => {
  const config = {
    apiUrl: 'https://api.dify.ai/v1',
    apiKey: 'app-j07Xbg1LZrwfXQ9ubGMMjeA1'
  };

  try {
    const response = await fetch(`${config.apiUrl}/chat-messages`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: {},
        query: '请简单介绍一下采购的基本流程',
        response_mode: 'streaming',
        conversation_id: '',
        user: 'test-user'
      })
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const reader = response.body?.getReader();
    const decoder = new TextDecoder();
    let buffer = '';

    if (reader) {
      console.log('开始接收流式响应...');
      
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        
        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';
        
        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6);
            if (data === '[DONE]') {
              console.log('流式响应结束');
              return;
            }
            try {
              const parsed = JSON.parse(data);
              if (parsed.event === 'message') {
                console.log('收到数据块:', parsed.data.answer || '');
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      }
    }
  } catch (error) {
    console.error('测试流式响应失败:', error);
  }
}; 