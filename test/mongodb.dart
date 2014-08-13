library tagdb.spec;

import 'dart:io';
import 'package:tagdb/server.dart';
import 'package:hub/hub.dart';

void main(){

  var mongo = TagDB.create('mongo',{
    'url':"mongodb://127.0.0.1/mydb",
    'port': 27017
  });
  mongo.open().then(Funcs.tag('booting mongodb')).then((f){

    mongo.query({
      'id':'all',
      'db':'mydb',
    }).then(Funcs.tag('mydb-all'));

    mongo.query({
      'id':'findOne',
      'db': 'mydb'
    }).then(Funcs.tag('mydb-findone'));
  
    mongo.query({
      'id':'insert',
      'db': 'mydb',
      'data':{'name':'john','age':31}
    }).then(Funcs.tag('mydb-insert'));

    mongo.query({
      'id':'update',
      'db': 'mydb',
      'criteria': [{'name':'alex'},{'\$set':{'status':'single'}},{'multiUpdate': true}]
    }).then(Funcs.tag('mydb-update'));

    mongo.query({
      'id':'find',
      'db': 'mydb',
      'criteria':[{'status': 'single'}]
    });

    mongo.query({
      'id':'drop',
      'db': 'mydb',
    }).then(Funcs.tag('mydb-drop')).then((n){
      mongo.end().then((f)=> print('ending mongo'));
    });
  }).catchError(Funcs.tag('mongodb error'));

}
