async function testBlockingAPI() {
  const config = {
    apiUrl: 'https://api.dify.ai/v1',
    apiKey: 'app-j07Xbg1LZrwfXQ9ubGMMjeA1'
  };

  try {
    console.log('开始测试非流式API...');
    
    const response = await fetch(`${config.apiUrl}/chat-messages`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: {},
        query: '请简单介绍一下采购的基本流程',
        response_mode: 'blocking',
        conversation_id: '',
        user: 'test-user'
      })
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log('非流式响应:', JSON.stringify(data, null, 2));
    
  } catch (error) {
    console.error('测试失败:', error);
  }
}

testBlockingAPI(); 