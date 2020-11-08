import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:koobook_project4/event.dart';
import 'package:koobook_project4/model/book.dart';
import 'package:koobook_project4/model/folder.dart';
import '../bloc.dart';

class ResultsPage extends StatefulWidget {
  TestBloc testBloc;
  final Folder folder;
  final String searchName;

  ResultsPage(this.testBloc, this.folder, this.searchName);
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final int _nextPageThreshold = 3;
  bool hasNextPage, loading, error;
  int pageNum;
  List<Book> bookList = new List();

  @override
  void initState() {
    super.initState();
    hasNextPage = true;
    pageNum = 1;
    error = false;
    loading = true;
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      Dio dio = new Dio();
      final response =
      await dio.get("https://api.koobook.app/books/", queryParameters: {
        "search": widget.searchName,
        "fields": "url,Title,ISBN,Image,Description,Publisher,Price,Edition,Hashtags,Rate,Authors",
        "page": pageNum,
      });
      List fetchedBooks = response.data['results'];
      setState(() {
        if (response.data['next'] == null) {
          hasNextPage = false;
        } else {
          pageNum++;
        }
        loading = false;
        for (int i = 0; i < fetchedBooks.length; i++) {
          String authorsName = "";
          for (int j = 0; j < fetchedBooks[i]['Authors'].length; j++) {
            authorsName += fetchedBooks[i]['Authors'][j]["Name"] + " ";
          }
          Book book = new Book(
              fetchedBooks[i]['url'],
              fetchedBooks[i]['Title'],
              fetchedBooks[i]['Image'],
              fetchedBooks[i]['Description'],
              fetchedBooks[i]['Publisher'],
              fetchedBooks[i]['Rate'],
              authorsName);
          bookList.add(book);
        }
        return true;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        body: getBody()
    );
  }

  Widget getBody() {
    if (bookList.isEmpty) {
      if (loading) {
        return Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ));
      } else if (error) {
        return Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  loading = true;
                  error = false;
                  fetchBooks();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Error while loading photos, tap to try agin"),
              ),
            ));
      }
    } else {
      return ListView.builder(
          itemCount: bookList.length + (hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == bookList.length - _nextPageThreshold) {
              fetchBooks();
            }
            if (index == bookList.length) {
              if (error) {
                return Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          loading = true;
                          error = false;
                          fetchBooks();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                            "Error while loading photos, tap to try agin"),
                      ),
                    ));
              } else {
                return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ));
              }
            }
            final Book book = bookList[index];
            return Card(
              elevation: 5,
              color: Colors.white,
              child: ListTile(
                title: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text("${book.title}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.amber.shade700,
                      )),
                ),
                subtitle: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.authors,
                          style:
                          TextStyle(color: Colors.grey.shade700),
                        ),
                        Text(
                          "${book.publisher}",
                          style:
                          TextStyle(color: Colors.grey.shade700),
                        ),
                      ]),
                ),
                trailing: CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade900,
                  backgroundImage: NetworkImage(
                    book.image,
                  ),
                ),
                onTap: () {
                  widget.folder.addBook(book);
                  widget.testBloc.add(GoToFolderDetail(widget.folder));
                },
              ),
            );
          });
    }
    return Container();
  }
}