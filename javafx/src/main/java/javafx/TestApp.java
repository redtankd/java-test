package javafx;

import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Orientation;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.SplitPane;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.FlowPane;
import javafx.stage.Popup;
import javafx.stage.Stage;
import javafx.stage.WindowEvent;

public class TestApp extends Application
{
    public static void main(String[] args) throws Exception
    {
        launch(args);
    }

    public void start(final Stage stage) throws Exception
    {
        final SplitPane rootPane = new SplitPane();
        rootPane.setOrientation(Orientation.VERTICAL);

        final FlowPane dockedArea = new FlowPane();
        dockedArea.getChildren().add(new Label("Some docked content"));

        FlowPane centerArea = new FlowPane();
        Button undockButton = new Button("Undock");
        undockButton.setOnAction(new EventHandler<ActionEvent>()
        {
            public void handle(ActionEvent actionEvent)
            {
                rootPane.getItems().remove(dockedArea);

                Dialog dialog = new Dialog();
                dialog.setOnHidden(new EventHandler<WindowEvent>()
                {
                    public void handle(WindowEvent windowEvent)
                    {
                        rootPane.getItems().add(dockedArea);
                    }
                });
                dialog.setContent(dockedArea);
                dialog.show(stage);
            }
        });
        centerArea.getChildren().add(undockButton);

        rootPane.getItems().addAll(centerArea, dockedArea);


        Scene scene = new Scene(rootPane, 300, 300);
        stage.setScene(scene);
        stage.show();
    }

    //-------------------------------------------------------------------------

    private class Dialog extends Popup
    {
        private BorderPane root;

        private Dialog()
        {
            root = new BorderPane();
            root.setPrefWidth(200);
            root.setPrefHeight(200);
            root.setStyle("-fx-border-width: 1; -fx-border-color: gray");
            root.setTop(buildTitleBar());
            getContent().add(root);
        }

        public void setContent(Node content)
        {
            root.setCenter(content);
        }

        private Node buildTitleBar()
        {
            BorderPane pane = new BorderPane();
            pane.setStyle("-fx-background-color: #0000aa; -fx-text-fill: white; -fx-padding: 5");

            pane.setOnMouseDragged(new EventHandler<MouseEvent>()
            {
                public void handle(MouseEvent event)
                {
                    // not sure why getX and getY don't work
                    // double x = getX() + event.getX();
                    // double y = getY() + event.getY();

                    double x = event.getScreenX();
                    double y = event.getScreenY();
                    setX(x);
                    setY(y);
                }
            });

            Label title = new Label("My Dialog");
            pane.setLeft(title);

            Button closeButton = new Button("X");
            closeButton.setOnAction(new EventHandler<ActionEvent>()
            {
                public void handle(ActionEvent actionEvent)
                {
                    hide();
                }
            });
            pane.setRight(closeButton);

            return pane;
        }
    }
}