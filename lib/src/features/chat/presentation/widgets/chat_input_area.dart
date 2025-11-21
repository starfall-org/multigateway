import 'package:flutter/material.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4), // Light grey background
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: Text(
                'Hỏi LMHub', // Changed from Gemini to LMHub
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.black87,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.image_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: onSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic_none, color: Colors.black87),
                  onPressed: () {},
                ),
                // Send Button (Replacing Sparkle)
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue, size: 20),
                    onPressed: () => onSubmitted(controller.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
