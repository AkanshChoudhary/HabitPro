import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:habit_pro/api_key.dart';

import 'package:habit_pro/data/data.dart';
import 'package:http/http.dart' as http;

Future<http.Response?> generateHabitData(String habitName,String habitDesc,String gender) async {
  try{
    return await http.post(
      Uri.parse(OPEN_AI_BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiKey'
      },
      body: jsonEncode(<String, dynamic>{
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "user",
            "content":
            "I am creating an application for providing users 21 days of tasks to make or break any habit, "
                "following the principle that any habit can be made or broken in 21 days. "
                "I want you to provide me 21 days worth of tasks for a $gender who wants to learn the habit \"$habitName\" with "
                "with habit description \"$habitDesc\""
                "Exercising. \n Rules: \n 1. Give me 21 discrete points for each day "
                "\n2. All day tasks should not be more than 2 sentences. (Keep it short and clear) "
                "\n3. You can add rest days or break days in between"
                "\n4. All the day tasks should be having incremental change and improvement and should connected to the previous day tasks."
                " (example: Day 3 and Day 4 tasks should not be totally different from each other, Day 4 tasks should add on improvement to work done in Day 3)"
                "\n5. make it fun for the user"
          }
        ]
      }),
    ).timeout(const Duration(seconds: 25));
  }
  catch (e){
    return null;
  }
}
