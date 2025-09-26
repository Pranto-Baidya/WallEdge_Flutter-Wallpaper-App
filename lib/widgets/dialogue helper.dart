
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alert{

  static void dialogue(BuildContext context, String title, String content,double? height){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.white,
            title: Text(title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: height ?? 5,),
                Text(content,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.black),),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Text('Okay',style: TextStyle(color: Colors.black,fontSize: 16),)
              )
            ],
          );
        }
    );
  }

}