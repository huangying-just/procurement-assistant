import axios from 'axios';
import { ChatResponse, DifyConfig } from '../types';
import { env } from '../config/env';

const config: DifyConfig = {
  apiUrl: env.DIFY_API_URL,
  apiKey: env.DIFY_API_KEY
};

const difyApi = axios.create({
  baseURL: config.apiUrl,
  headers: {
    'Authorization': `Bearer ${config.apiKey}`,
    'Content-Type': 'application/json'
  }
});

export const sendMessage = async (
  message: string, 
  conversationId?: string,
  onStream?: (chunk: string) => void
): Promise<ChatResponse> => {
  try {
    if (onStream) {
      // 流式响应
      const response = await fetch(`${config.apiUrl}/chat-messages`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${config.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          inputs: {},
          query: message,
          response_mode: 'streaming',
          conversation_id: conversationId,
          user: 'user'
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('HTTP错误:', response.status, errorText);
        throw new Error(`HTTP error! status: ${response.status}, message: ${errorText}`);
      }

      const reader = response.body?.getReader();
      const decoder = new TextDecoder();
      let buffer = '';
      let finalConversationId = conversationId || '';
      let finalMessageId = '';
      let fullAnswer = '';
      let hasReceivedData = false;

      if (reader) {
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
                break;
              }
              
              if (data.trim() === '') {
                continue;
              }
              
              try {
                const parsed = JSON.parse(data);
                
                // 处理不同的事件类型
                if (parsed.event === 'message') {
                  // 更新会话和消息ID
                  if (parsed.conversation_id) {
                    finalConversationId = parsed.conversation_id;
                  }
                  if (parsed.message_id) {
                    finalMessageId = parsed.message_id;
                  }
                  
                  // 检查answer字段 - 可能在不同位置
                  let answerText = '';
                  if (parsed.answer) {
                    answerText = parsed.answer;
                  } else if (parsed.data && parsed.data.answer) {
                    answerText = parsed.data.answer;
                  }
                  
                  if (answerText && typeof answerText === 'string' && answerText.length > 0) {
                    fullAnswer += answerText;
                    hasReceivedData = true;
                    onStream(answerText);
                  }
                }
                else if (parsed.event === 'message_end') {
                  if (parsed.conversation_id) {
                    finalConversationId = parsed.conversation_id;
                  }
                  if (parsed.message_id) {
                    finalMessageId = parsed.message_id;
                  }
                }
                else if (parsed.event === 'workflow_finished') {
                  // 有时完整答案在这里
                  if (parsed.data && parsed.data.outputs && parsed.data.outputs.answer) {
                    const workflowAnswer = parsed.data.outputs.answer;
                    if (!hasReceivedData && workflowAnswer) {
                      fullAnswer = workflowAnswer;
                      hasReceivedData = true;
                      onStream(workflowAnswer);
                    }
                  }
                }
              } catch (e) {
                console.error('解析JSON错误:', e, '原始数据:', data);
              }
            }
          }
        }
      }
      
      // 如果没有收到任何数据，尝试使用阻塞模式作为备选
      if (!hasReceivedData) {
        console.log('流式模式未收到数据，尝试阻塞模式...');
        const fallbackResponse = await difyApi.post('/chat-messages', {
          inputs: {},
          query: message,
          response_mode: 'blocking',
          conversation_id: conversationId,
          user: 'user'
        });
        
        if (fallbackResponse.data.answer) {
          onStream(fallbackResponse.data.answer);
          return fallbackResponse.data;
        } else {
          throw new Error('API返回了空响应，请检查API配置和网络连接');
        }
      }
      
      // 返回最终响应
      return {
        answer: fullAnswer,
        conversation_id: finalConversationId,
        message_id: finalMessageId || Date.now().toString()
      };
    } else {
      // 非流式响应（兼容性）
      const response = await difyApi.post('/chat-messages', {
        inputs: {},
        query: message,
        response_mode: 'blocking',
        conversation_id: conversationId,
        user: 'user'
      });
      
      return response.data;
    }
  } catch (error) {
    console.error('发送消息错误:', error);
    if (error instanceof Error) {
      throw new Error(`发送消息失败: ${error.message}`);
    } else {
      throw new Error('发送消息失败，请稍后重试');
    }
  }
};

export const getSuggestedQuestions = (): string[] => {
  return [
    '我们单位需要采购50台办公电脑，就是普通的台式机，用于日常办公，预算大概30万。',
    '我们数据中心的核心交换机突然被雷击损坏，导致全公司内网瘫痪，业务完全中断。我们需要立刻找到有原厂授权和备件的公司进行抢修，恢复业务是第一位的，等不及走常规流程了。'
  ];
}; 