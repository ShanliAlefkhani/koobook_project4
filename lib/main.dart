import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koobook_project4/screens/BlocHandler.dart';
import 'BlockDelegate.dart';
import 'bloc.dart';

void main() {
  BlocSupervisor.delegate = AppBlocDelegate();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<TestBloc>(
        create: (context) => TestBloc(),
      ),
    ],
    child: MaterialApp(home: TestingPage()),
  ));
}