package com.lint.diablo.mylint;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        System.out.println("ss");
        TextView textView = (TextView) findViewById(R.id.text);
        textView.setText("妈的智障");
    }
}
