import 'dart:io' as io;
import 'dart:ui';
import 'dart:async';
import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file/local.dart';
import 'package:splitter_module/paymentAssistant.dart';
import 'package:splitter_module/splitAssistant.dart';





class RecordNPlay extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  RecordNPlay({localFileSystem,})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _RecordNPlayState createState() => _RecordNPlayState();
}

class _RecordNPlayState extends State<RecordNPlay> {
  AudioPlayer _splitFileAudioPlayer = AudioPlayer();
  bool _splitAudioStatus = false;
  bool isSplitFilePlaying = false;
  String splitFileCurrentTime = "00:00";
  String splitFileCompleteTime= "00:00";

  List<String> records;
  List<String> splitRecords;

  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;



  @override
  void initState() {
    super.initState();

    _splitFileAudioPlayer.onAudioPositionChanged.listen((Duration duration){
      setState(() {
        splitFileCurrentTime = duration.toString().split(".")[0];
      });
    });

    _splitFileAudioPlayer.onDurationChanged.listen((Duration duration){
      setState(() {
        splitFileCompleteTime = duration.toString().split(".")[0];
      });
    });

    records = [];
    splitRecords = [];
    _init();


  }

  @override
  void dispose() {
    records = null;
    _splitFileAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_currentStatus);
    double size = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.audiotrack),
            onPressed: () async{
              try{
                FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.any);


                if(result !=null){

                  String filePath = result.files.single.path;


                  int status = await _splitFileAudioPlayer.play(filePath, isLocal: true);

                  if(status == 1){
                    setState(() {
                      _splitAudioStatus = true;
                      isSplitFilePlaying = true;
                    });
                  }else{
                    setState(() {
                      isSplitFilePlaying = false;
                    });
                  }

                }else{
                  showToast(context, 'couldn\'t get a music file', null, true);
                  setState(() {
                    isSplitFilePlaying = false;
                  });
                }

              }catch(e){

                showToast(context, e.toString(), null, true);

              }

            },
          ),
          SizedBox(height: 10,),

          FloatingActionButton(
            child: _buildIcon(_currentStatus),
            onPressed: (){
              if(!isSplitFilePlaying){
                switch (_currentStatus) {
                  case RecordingStatus.Initialized:
                    {
                      _start();
                      break;
                    }
                  case RecordingStatus.Recording:
                    {
                      _stop();
                      break;
                    }
                  case RecordingStatus.Paused:
                    {
                      _resume();
                      break;
                    }
                  case RecordingStatus.Stopped:
                    {
                      _init();
                      break;
                    }
                  default:
                    break;
                }
              }else
                showToast(context, 'please select audio before recording', null, true);
            },
          ),
          SizedBox(height: 10,),

          FloatingActionButton(
            child: Icon(Icons.upload_file),
            onPressed: () async{



              try{

                FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.audio);

                if(result != null) {
                  String filePath = result.files.single.path;

                  var isSplitandSaved = await SplitAssistant.splitFile(filePath);
                  if (isSplitandSaved != "Failed" && isSplitandSaved != null){
                    showToast(context, 'split sucessfully', Colors.green, false);
                    bool isSaved = await SplitAssistant.saveSplitFiles(isSplitandSaved);
                    if(isSaved){
                      showToast(context, 'ssaved sucessfully', Colors.green, false);
                      setState(() {
                        String bass = isSplitandSaved['files']['bass'];
                        String drums = isSplitandSaved['files']['drums'];
                        String vocals = isSplitandSaved['files']['voice'];
                        String other = isSplitandSaved['files']['other'];

                        print(bass);
                        print(drums);
                        print(vocals);
                        print(other);

                        splitRecords.add(bass);
                        splitRecords.add(drums);
                        splitRecords.add(vocals);
                        splitRecords.add(other);

                      });
                    }else
                      showToast(context, 'ssaved failed', Colors.green, false);
                  }
                  else
                    showToast(context, 'split failed', null, true);

                } else {
                  showToast(context, 'you didn\'t select a file', null, true);
                }


              }catch(e){
                print(e.toString());
                showToast(context, e.toString(), null, true);
              }

            },
          ),
          SizedBox(height: 10,),

          FloatingActionButton(
            child: Icon(Icons.payment),
            onPressed: () async{
              var result = await PaymentAssistant.processTransaction(context);
              if(result == "Failed")
                showToast(context, 'Payment Failed', null, true);
              else if (result == "Cancelled")
                showToast(context, 'Transaction cancelled by user', null, true);
              else{
                showToast(context, 'Payment Successful', Colors.green, false);
                // TODO: DO SOMETHING WITH THE RESULT
              }
            },
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/12.jpg",), fit: BoxFit.cover,),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: size * 0.1),
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [

                      IconButton(icon: isSplitFilePlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow), onPressed: (){
                        if(isSplitFilePlaying && _splitAudioStatus){
                          _splitFileAudioPlayer.pause();

                          setState(() {
                            isSplitFilePlaying = false;
                          });
                        }else if (!isSplitFilePlaying && _splitAudioStatus){
                          _splitFileAudioPlayer.resume();

                          setState(() {
                            isSplitFilePlaying = true;
                          });
                        }else{
                          showToast(context, 'No Audio Selected', null, true);
                        }
                      }),

                      SizedBox(width: 16,),

                      IconButton(icon: Icon(Icons.stop), onPressed: (){
                        _splitFileAudioPlayer.stop();

                        setState(() {
                          isSplitFilePlaying = false;
                        });
                      }),

                      Text(splitFileCurrentTime, style: TextStyle(fontWeight: FontWeight.w700),),

                      Text(" | "),

                      Text(splitFileCompleteTime, style: TextStyle(fontWeight: FontWeight.w300),),
                    ],
                  ),
                ),

                Flexible(
                  child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: size * 0.05),
                      padding: EdgeInsets.only(left: 10, right: 10, top: size * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: splitRecords.length > 0 ? RecordListScreen(
                        records: splitRecords,
                        isSplitRecord: true,
                      ) : Center(child: Text('No Split Records yet', style: TextStyle(fontWeight: FontWeight.w700),), )
                  ),
                ),


                Flexible(
                  child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: size * 0.05),
                      padding: EdgeInsets.only(left: 10, right: 10, top: size * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: records.length > 0 ? RecordListScreen(
                        records: records,
                        isSplitRecord: false
                      ) : Center(child: Text('No records yet', style: TextStyle(fontWeight: FontWeight.w700),), )
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );


  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _resume() async {
    await _recorder.resume();
    setState(() {});
  }

  _pause() async {
    await _recorder.pause();
    setState(() {});
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
      records.add(_current.path);
    });
  }

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
  }

  Widget _buildIcon(RecordingStatus status) {
    IconData icon;
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          icon = Icons.mic;
          break;
        }
      case RecordingStatus.Recording:
        {
          icon = Icons.stop;
          break;
        }
      case RecordingStatus.Paused:
        {
          icon = Icons.mic;
          break;
        }
      case RecordingStatus.Stopped:
        {
          icon = Icons.mic_none;
          break;
        }
      default:
        icon = Icons.mic;
        break;
    }
    return Icon(icon, color: Colors.white,);
  }



}

showToast(context, String msg, Color color, bool isError) {
  FToast fToast = FToast();
  fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: color != null ? color : Colors.redAccent,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isError ? Icons.cancel : Icons.check, size: 20, color: Colors.white),
        SizedBox(
          width: 12.0,
        ),
        Text(msg, textAlign: TextAlign.start, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.TOP,
    toastDuration: Duration(seconds: 2),
  );

}


class RecordListScreen extends StatefulWidget {
  final List<String> records;
  final bool isSplitRecord;
  const RecordListScreen({
    Key key,
    this.records,
    this.isSplitRecord,
  }) : super(key: key);
  @override
  _RecordListScreenState createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  int _totalDuration;
  int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isRecorderAudioPlaying = false;
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.records.length,
      shrinkWrap: true,
      reverse: true,
      itemBuilder: (_ , index ){
        return ExpansionTile(
          title: widget.isSplitRecord && index == 0 ? Text('Bass') : widget.isSplitRecord && index == 1 ? Text('Drums') : widget.isSplitRecord && index == 2 ? Text('Vocal') : widget.isSplitRecord && index == 3 ? Text('Other') : Text('New recording ${widget.records.length - index}'),
          subtitle: Text('2021/Apr/14'),
          onExpansionChanged: ((change) {
            if (change) {
              setState(() {
                _selectedIndex = index;
              });
            }
          }),
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    value: _selectedIndex == index ? _completedPercentage : 0,
                  ),
                  IconButton(
                    icon: _selectedIndex == index && _isRecorderAudioPlaying
                        ? Icon(Icons.pause)
                        : Icon(Icons.play_arrow),
                    onPressed: () => _onPlay(
                        filePath: widget.records.elementAt(index), index: index),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onPlay({@required String filePath, @required int index}) async {
    AudioPlayer recorderAudioPlayer = AudioPlayer();

    if (!_isRecorderAudioPlaying) {
      recorderAudioPlayer.play(filePath, isLocal: widget.isSplitRecord ? false : true);
      setState(() {
        _selectedIndex = index;
        _completedPercentage = 0.0;
        _isRecorderAudioPlaying = true;
      });

      recorderAudioPlayer.onPlayerCompletion.listen((_) {
        setState(() {
          _isRecorderAudioPlaying = false;
          _completedPercentage = 0.0;
        });
      });
      recorderAudioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration.inMicroseconds;
        });
      });

      recorderAudioPlayer.onAudioPositionChanged.listen((duration) {
        setState(() {
          _currentDuration = duration.inMicroseconds;
          _completedPercentage =
              _currentDuration.toDouble() / _totalDuration.toDouble();
        });
      });
    }else{
      recorderAudioPlayer.pause();
      setState(() {
        _isRecorderAudioPlaying = false;
      });
    }
  }


}







