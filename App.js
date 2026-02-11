import React, { useState } from 'react';
import { StyleSheet, View, Text, TextInput, FlatList, TouchableOpacity, SafeAreaView } from 'react-native';

export default function App() {
  const [messages, setMessages] = useState([
    { id: '1', text: 'مرحباً! هذا الاتصال مشفر بالكامل ولا يمكن تعقبه.', sender: 'system' }
  ]);
  const [inputText, setInputText] = useState('');

  const sendMessage = () => {
    if (inputText.trim() === '') return;
    const newMessage = { id: Date.now().toString(), text: inputText, sender: 'me' };
    setMessages([...messages, newMessage]);
    setInputText('');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Secure Chat (No-Log)</Text>
      </View>
      <FlatList
        data={messages}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <View style={[styles.messageBox, item.sender === 'me' ? styles.myMessage : styles.theirMessage]}>
            <Text style={styles.messageText}>{item.text}</Text>
          </View>
        )}
        style={styles.chatList}
      />
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="اكتب رسالة آمنة..."
          placeholderTextColor="#aaa"
          value={inputText}
          onChangeText={setInputText}
        />
        <TouchableOpacity style={styles.sendButton} onPress={sendMessage}>
          <Text style={styles.sendButtonText}>➤</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0e1621' },
  header: { height: 60, backgroundColor: '#17212b', justifyContent: 'center', alignItems: 'center' },
  headerTitle: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
  chatList: { flex: 1, padding: 10 },
  messageBox: { padding: 10, borderRadius: 15, marginVertical: 5, maxWidth: '80%' },
  myMessage: { alignSelf: 'flex-end', backgroundColor: '#2b5278' },
  theirMessage: { alignSelf: 'flex-start', backgroundColor: '#182533' },
  messageText: { color: '#fff', fontSize: 16 },
  inputContainer: { flexDirection: 'row', padding: 10, backgroundColor: '#17212b' },
  input: { flex: 1, color: '#fff', backgroundColor: '#242f3d', borderRadius: 20, paddingHorizontal: 15, height: 40 },
  sendButton: { marginLeft: 10, width: 45, height: 45, backgroundColor: '#5288c1', borderRadius: 22.5, justifyContent: 'center', alignItems: 'center' },
  sendButtonText: { color: '#fff', fontSize: 20 }
});
