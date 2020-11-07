import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koobook_project4/model/folder.dart';
import 'package:koobook_project4/screens/FirstPage.dart';
import '../bloc.dart';
import '../state.dart';
import 'FolderDetail.dart';

class TestingPage extends StatefulWidget {
  @override
  _TestingPageState createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  TestBloc testBloc;

  @override
  void initState() {
    super.initState();
    testBloc = BlocProvider.of<TestBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Center(
          child: BlocBuilder<TestBloc, TestState>(
            builder: (context, state) {
              if (state is Home) {
                return FirstPage(testBloc);
              }
              else if (state is FolderDetailInit) {
                Folder folder = state.folder;
                return FolderDetail(testBloc, folder);
              }
              else {
                return Scaffold(body: Center(child: Text("loading"),),);
              }
            },
          )
      ),
    );
  }
}