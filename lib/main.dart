import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(FriendlyChatApp());
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,

  /**
   * The kDefaultTheme ThemeData object specifies colors for Android (purple with orange accents).
   * The kIOSTheme ThemeData object specifies colors for iOS (light grey with orange accents).
   **/
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

String _name = 'Richard';

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriendlyChat',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      //The top-level defaultTargetPlatform property and conditional operators are used to select the theme.
      home: ChatScreen(),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({required this.text, required this.animationController});

  final String text;
  final AnimationController animationController;

  // const ChatMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          //assigns the child to the highest position along the vertical axis cos its Row
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                child:
                Text(_name[0]), //to get the 1st letter of the entered name
              ),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //assigns the child to the highest position along the horizontal axis cos its Column
                  children: [
                    Text(
                      _name, //name of sender
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline4,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5.0),
                      child: Text(text), //message
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = []; //defined list of ChatMessage type
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('FriendlyChat'),
          elevation:
          Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0, // NEW
        ),

        body: Column(
          children: [
            Flexible(
              //makes the list come ahead of text field in the column layout
                child: ListView.builder(
                  //builds a list based on the properties of its children
                  padding: EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  //Naming the argument with an underscore (_) and nothing else is a convention indicating that the argument won't be used.
                  itemCount: _messages.length,
                )),
            Divider(
              //draws a horizontal line between the message and text input UI
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(color: Theme
                  .of(context)
                  .cardColor),
              child: _buildTextComposer(),
            ),
          ],
    //     decoration: Theme
    //         .of(context)
    //         .platform == TargetPlatform.iOS // NEW
    //         ? BoxDecoration( // NEW
    //       border: Border( // NEW
    //         top: BorderSide(color: Colors.grey[200]!), // NEW
    //       ), // NEW
    //     ) // NEW
    //         : null)
    // , // MODIFIED
    ));

  }

  Widget _buildTextComposer() {
    return IconTheme(
      //to make icons inherit the color opacity and size from the below defined IconTheme widget
        data: IconThemeData(color: Theme
            .of(context)
            .accentColor),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          //adds a horizontal margin between the edge of the screen and each side of the input field
          child: Row(children: [
            Flexible(
              //tells the row to automatically size the text field to use the remaining space left by the button
              child: TextField(
                controller: _textController,
                //gives control over the text field (to handle the value)
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text
                        .isNotEmpty; //sets to false if text field is not empty
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration:
                InputDecoration.collapsed(hintText: 'Send a message'),
                focusNode:
                _focusNode, //put the focus back on the text after content submission
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme
                  .of(context)
                  .platform == TargetPlatform.iOS
                  ? CupertinoButton(
                  child: Text('Send'),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null)
                  : IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              ),
            )
          ]),
        ));
  }

  void _handleSubmitted(String text) {
    _textController.clear(); //clears the text field
    setState(() {
      _isComposing = false;
    });
    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
          duration: const Duration(milliseconds: 700),
          //animation duration is set to 7 seconds
          vsync: this),
    ); //put the gotten text from text field into a variable
    setState(() {
      /**
       * Calling setState()to modify _messages lets the framework know that this part of the widget tree changed, and it needs to rebuild the UI.
       * Only synchronous operations should be performed in setState() because otherwise the framework could rebuild the widgets before the operation finishes.
       * **/
      _messages.insert(0, message); // insert the gotten text into the list
    });
    _focusNode
        .requestFocus(); //request focus after the message has been added to the list
    message.animationController
        .forward(); //animation is set to play forward whenever a message is added to the chat list
  }

  void dispose() {
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}
