import 'dart:convert';
import 'package:http/http.dart' as http;


class SplitAssistant{

  static Future<dynamic> splitFile(String filePath) async{
    String baseUrl = "http://67.205.165.56/api/splitter?";

    try{

      var postUri = Uri.parse(baseUrl);
      var request = new http.MultipartRequest("POST", postUri);
      request.fields['token'] = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC82Ny4yMDUuMTY1LjU2IiwiYXVkIjoiaHR0cDpcL1wvNjcuMjA1LjE2NS41NiIsImlhdCI6MTM1Njk5MTUyNCwibmJmIjoxMzU3MDAxMDAwLCJlbWFpbCI6Im9hbnRob255NTkwQGdtYWlsLmNvbSJ9.bE-sdlodX1zMM6Lo0s5RtuVqSlrNq1QJ5vBk6rU-hxI';
      request.files.add( await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200){
        String jsonData = await response.stream.bytesToString();
        print(jsonData);
        var decodedData = jsonDecode(jsonData);
        print(decodedData);
        return decodedData;
      }
      else{
        return "Failed";
      }

    }catch(e){
      return "Failed";
    }
  }


  static Future<bool> saveSplitFiles(var decodedData) async{

    String baseUrl = "http://67.205.165.56/api/savesplit";


    var body = jsonEncode({
      "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC82Ny4yMDUuMTY1LjU2IiwiYXVkIjoiaHR0cDpcL1wvNjcuMjA1LjE2NS41NiIsImlhdCI6MTM1Njk5MTUyNCwibmJmIjoxMzU3MDAxMDAwLCJlbWFpbCI6Im9hbnRob255NTkwQGdtYWlsLmNvbSJ9.bE-sdlodX1zMM6Lo0s5RtuVqSlrNq1QJ5vBk6rU-hxI",
      "id":decodedData['id'],
      "title":decodedData['title'],
      "files": {
        "bass": decodedData['files']['bass'],
        "voice": decodedData['files']['voice'],
        "drums": decodedData['files']['drums'],
        "other": decodedData['files']['other']
      }
    });

    try{

      final _response = await http.post(baseUrl, headers: {
        'Content-Type': 'application/json',
      }, body:body);


      if (_response.statusCode == 200){
        return Future.value(true);
      }
      else{
        return Future.value(false);
      }
    }catch(e){
      return Future.value(false);
    }
  }

  static Future<bool> getSplitFiles(String url) async{
    String baseUrl = url;

    var body = jsonEncode({
      "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC82Ny4yMDUuMTY1LjU2IiwiYXVkIjoiaHR0cDpcL1wvNjcuMjA1LjE2NS41NiIsImlhdCI6MTM1Njk5MTUyNCwibmJmIjoxMzU3MDAxMDAwLCJlbWFpbCI6Im9hbnRob255NTkwQGdtYWlsLmNvbSJ9.bE-sdlodX1zMM6Lo0s5RtuVqSlrNq1QJ5vBk6rU-hxI",
      "id":25646957,
      "title":"Gyakie_Forever_Remix_Omah_Lay_9jaflaver.com_.mp3_1618398789.mp3",
      "files":{"bass":"http:\/\/69.55.59.149\/musics\/511704797\/Gyakie_Forever_Remix_Omah_Lay_9jaflaver.com_.mp3_1618398789\/bass.wav",
        "voice":"http:\/\/69.55.59.149\/musics\/511704797\/Gyakie_Forever_Remix_Omah_Lay_9jaflaver.com_.mp3_1618398789\/vocals.wav",
        "drums":"http:\/\/69.55.59.149\/musics\/511704797\/Gyakie_Forever_Remix_Omah_Lay_9jaflaver.com_.mp3_1618398789\/drums.wav",
        "other":"http:\/\/69.55.59.149\/musics\/511704797\/Gyakie_Forever_Remix_Omah_Lay_9jaflaver.com_.mp3_1618398789\/other.wav"}}
    );

    try{
      final _response = await http.post(baseUrl, headers: {
        'Content-Type': 'application/json',
      }, body:body);

      print(_response.request);
      print(_response.statusCode);
      print(_response.body);

      if (_response.statusCode == 200)
        return Future.value(true);
      else
        return Future.value(false);
    }catch(e){
      return Future.value(false);
    }
  }


}