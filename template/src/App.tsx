import React, { useState, useRef, useEffect } from 'react';
import ChatMessage from './components/ChatMessage';
import ChatInput from './components/ChatInput';
import SuggestedQuestions from './components/SuggestedQuestions';
import { Message } from './types';
import { sendMessage, getSuggestedQuestions } from './services/difyApi';
import { env } from './config/env';
import { ShoppingCart, Bot } from 'lucide-react';

const App: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [conversationId, setConversationId] = useState<string | undefined>();
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const suggestedQuestions = getSuggestedQuestions();

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async (content: string) => {
    const userMessage: Message = {
      id: Date.now().toString(),
      content,
      role: 'user',
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setIsLoading(true);

    // 创建AI回复消息
    const assistantMessageId = (Date.now() + 1).toString();
    const assistantMessage: Message = {
      id: assistantMessageId,
      content: '',
      role: 'assistant',
      timestamp: new Date()
    };

    setMessages(prev => [...prev, assistantMessage]);

    try {
      const response = await sendMessage(content, conversationId, (chunk: string) => {
        // 流式更新消息内容
        setMessages(prev => prev.map(msg => 
          msg.id === assistantMessageId 
            ? { ...msg, content: msg.content + chunk }
            : msg
        ));
      });
      
      // 更新会话ID
      if (response.conversation_id) {
        setConversationId(response.conversation_id);
      }

      // 更新最终消息ID
      if (response.message_id) {
        setMessages(prev => prev.map(msg => 
          msg.id === assistantMessageId 
            ? { ...msg, id: response.message_id }
            : msg
        ));
      }
      
      // 如果没有收到流式数据，显示完整回答
      if (response.answer && !messages.find(m => m.id === assistantMessageId)?.content) {
        setMessages(prev => prev.map(msg => 
          msg.id === assistantMessageId 
            ? { ...msg, content: response.answer }
            : msg
        ));
      }
      
    } catch (error) {
      console.error('发送消息失败:', error);
      
      // 更新错误消息
      const errorMessage = error instanceof Error ? error.message : '发送消息失败，请稍后重试';
      setMessages(prev => prev.map(msg => 
        msg.id === assistantMessageId 
          ? { ...msg, content: `❌ ${errorMessage}` }
          : msg
      ));
    } finally {
      setIsLoading(false);
    }
  };

  const handleQuestionClick = (question: string) => {
    handleSendMessage(question);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
              <ShoppingCart className="text-white" size={24} />
            </div>
            <div>
              <h1 className="text-xl font-bold text-gray-900">{env.APP_NAME}</h1>
              <p className="text-sm text-gray-600">{env.APP_DESCRIPTION}</p>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="bg-white rounded-lg shadow-sm border min-h-[700px]">
          {/* Chat Messages */}
          <div className="h-[600px] overflow-y-auto p-6">
            {messages.length === 0 ? (
              <div className="text-center py-12">
                <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Bot className="text-primary-600" size={32} />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  欢迎使用{env.APP_NAME}
                </h3>
                <p className="text-gray-600 mb-6">
                  您可以在这里问我相关的采购需求问题，我会援引相关的政策法规给你建议。
                </p>
                <SuggestedQuestions 
                  questions={suggestedQuestions} 
                  onQuestionClick={handleQuestionClick} 
                />
              </div>
            ) : (
              <div>
                {messages.map((message) => (
                  <ChatMessage key={message.id} message={message} />
                ))}
                {isLoading && (
                  <div className="flex justify-start mb-4">
                    <div className="flex items-start">
                      <div className="flex-shrink-0 w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center">
                        <Bot size={16} className="text-gray-600" />
                      </div>
                      <div className="mx-3 px-4 py-3 bg-gray-100 rounded-lg">
                        <div className="flex space-x-1">
                          <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                          <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                          <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
                <div ref={messagesEndRef} />
              </div>
            )}
          </div>

          {/* Chat Input */}
          <div className="border-t p-6">
            <ChatInput onSendMessage={handleSendMessage} disabled={isLoading} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default App; 