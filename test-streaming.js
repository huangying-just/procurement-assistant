async function testStreamingAPI() {
  const config = {
    apiUrl: 'https://api.dify.ai/v1',
    apiKey: 'app-j07Xbg1LZrwfXQ9ubGMMjeA1'
  };

  try {
    console.log('开始测试流式API...');
    
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

    console.log('响应状态:', response.status);
    console.log('响应头:', response.headers);

    const reader = response.body;
    const decoder = new TextDecoder();
    let buffer = '';
    let fullAnswer = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';
      
      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = line.slice(6);
          console.log('原始数据:', data);
          
          if (data === '[DONE]') {
            console.log('流式响应结束');
            console.log('完整回答:', fullAnswer);
            return;
          }
          
          try {
            const parsed = JSON.parse(data);
            console.log('解析后的数据:', parsed);
            
            if (parsed.event === 'message') {
              const chunk = parsed.data.answer || '';
              fullAnswer += chunk;
              console.log('收到数据块:', chunk);
            }
          } catch (e) {
            console.error('解析错误:', e);
          }
        }
      }
    }
  } catch (error) {
    console.error('测试失败:', error);
  }
}

testStreamingAPI(); 