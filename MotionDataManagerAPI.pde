import oscP5.*;

class MotionDataManager{
    int NUM_BONE = 25;                    //骨格の頂点数
    PVector[] outcoming_bone_data;            //骨格データを格納する配列
    boolean isUsingRecordedData = false;  //保存したCSVデータを使用するかどうかのブーリアン
    
    CsvManager csvManager;                 //保存済みデータを使用する際のクラス
    
    
    OscP5 oscP5;

    PVector basePosition;
    float baseScale;

    MotionDataManager()
    {
        this.oscP5 = new OscP5(this, 12000);

        this.outcoming_bone_data = new PVector[this.NUM_BONE];
        for(int i = 0; i < NUM_BONE; i ++)
        {
            this.outcoming_bone_data[i] = new PVector();
        }

        this.isUsingRecordedData = false;
        this.basePosition = new PVector();
        this.csvManager = new CsvManager();

        this.baseScale = 100;
    }

    void oscEvent(OscMessage theOscMessage) {
 
     for (int i = 0; i < this.NUM_BONE; i ++)
     {
       if (theOscMessage.checkAddrPattern("/" + String.valueOf(i))==true)
       {
         this.outcoming_bone_data[i].x = theOscMessage.get(0).floatValue(); 
         this.outcoming_bone_data[i].y = theOscMessage.get(1).floatValue(); 
         this.outcoming_bone_data[i].z = theOscMessage.get(2).floatValue();
       }
     }

   }

    void setBasePosition(float x, float y, float z)
    {
        this.basePosition.x = x;
        this.basePosition.y = y;
        this.basePosition.z = z;
    }

    void setBaseScale(float s)
    {
        this.baseScale = s;
    }

    void setDataMode(boolean mode)
    {
        this.isUsingRecordedData = mode;
    }

    void setDataPath(String path)
    {
        this.csvManager = new CsvManager(path);
    }

    void update()
    {
        if(!this.isUsingRecordedData)
        {
            this.csvManager.setData(this.outcoming_bone_data);
        }
        else 
        {
            this.csvManager.updateFrameNumber();
        }
    }

    int getBoneNum()
    {
        return this.NUM_BONE;
    }

    PVector getBoneData(int id)
    {
        PVector p = new PVector();
        if(id >= 0 && id < this.NUM_BONE)
        {
            if(!this.isUsingRecordedData)
            {
                p.x = this.outcoming_bone_data[id].x;
                p.y = this.outcoming_bone_data[id].y;
                p.z = this.outcoming_bone_data[id].z;
            }
            else
            {
                p.x = this.csvManager.getdefault_data(id).x;
                p.y = this.csvManager.getdefault_data(id).y;
                p.z = this.csvManager.getdefault_data(id).z;
            }

            p.y *= -1;
            p.z *= -1;

            p.add(this.basePosition);
            p.mult(this.baseScale);
        }
        else
        {
            println("[MDMAPI-ERROR]:incorrect id value");
        }

        return p;
    }

    PVector getBoneData(String boneName)
    {
        int id;
        switch (boneName) {
            case "SpineBase":
                id = 0;
            break;

            case "SpineMid":
                id = 1;
            break;

            case "Neck":
                id = 2;
            break;

            case "Head":
                id = 3;
            break;

            case "ShoulderLeft":
                id = 4;
            break;

            case "ElbowLeft":
                id = 5;
            break;

            case "WristLeft":
                id = 6;
            break;

            case "HandLeft":
                id = 7;
            break;

            case "ShoulderRight":
                id = 8;
            break;

            case "ElbowRight":
                id = 9;
            break;

            case "WristRight":
                id = 10;
            break;

            case "HandRight":
                id = 11;
            break;

            case "HipLeft":
                id = 12;
            break;

            case "KneeLeft":
                id = 13;
            break;

            case "AnkleLeft":
                id = 14;
            break;

            case "FootLeft":
                id = 15;
            break;

            case "HipRight":
                id = 16;
            break;

            case "KneeRight":
                id = 17;
            break;

            case "AnkleRight":
                id = 18;
            break;

            case "FootRight":
                id = 19;
            break;

            case "SpineShoulder":
                id = 20;
            break;

            case "HandTipLeft":
                id = 21;
            break;

            case "ThumbLeft":
                id = 22;
            break;

            case "HandTipRight":
                id = 23;
            break;

            case "ThumbRight":
                id = 24;
            break;

            default :
                id = -1;
            break;              
        }

        return this.getBoneData(id);
    }

    void beginMotionRec()
    {
        this.csvManager.beginCsvRecord();
    }

    void stopMotionRec()
    {
        this.csvManager.saveData();
    }

    void stopMotionRec(String name)
    {
        this.csvManager.saveData(name);
    }

    void clearMotionRec()
    {
        this.csvManager.clearCsvRecord();
    }

    void drawGrid(int n_line, int line_interval)
    {
        for(int i = 0; i <= n_line; i ++)
        {
            float _i = i - n_line * 0.5;

            line(_i * line_interval, 0, -n_line * 0.5 * line_interval,
                _i * line_interval, 0,  n_line * 0.5 * line_interval);
                
            line(-n_line * 0.5 * line_interval, 0, _i * line_interval, 
                n_line * 0.5 * line_interval, 0, _i * line_interval);
        }
    }

}


class CsvManager {
  Table default_data = null;
  Table created_data = null;
  int max_frame;
  int n_frame;
  int n_frame_rec;
  int n_column = 75;
  boolean enableSave;

  CsvManager()
  {
    this("PositionData.csv");
  }

  CsvManager(String fileName)
  {
    this.default_data = loadTable(fileName);
    if ( this.default_data != null ) {
        println("[CSVM]RECORDED DATA INFO");
        println( ">RAW_COUNT: " + this.default_data.getRowCount());
        println( ">COLUNMN_COUNT: " + this.default_data.getColumnCount());

        this.max_frame = default_data.getRowCount();
    }

    this.n_frame = 0;

    this.created_data = new Table();

    for(int i = 0; i < this.n_column; i ++)
    {
        this.created_data.addColumn();
    }
  }

  PVector getdefault_data(int id)
  {
    PVector pd = new PVector();
    
    pd.x = this.default_data.getFloat(this.n_frame%this.max_frame, id * 3 + 0);
    pd.y = this.default_data.getFloat(this.n_frame%this.max_frame, id * 3 + 1);
    pd.z = this.default_data.getFloat(this.n_frame%this.max_frame, id * 3 + 2);

    return pd;
  }

  void updateFrameNumber()
  {
    this.n_frame ++;
  }

  void clearCsvRecord()
  {
      this.enableSave = false;
      this.n_frame_rec = 0;
      this.created_data = null;
  }

  void beginCsvRecord()
  {
      println("[CSVM] RECORD BEGIN!!!");
      this.created_data = new Table();

      for(int i = 0; i < this.n_column; i ++)
      {
        this.created_data.addColumn();
      }

      this.enableSave = true;
      this.n_frame_rec = 0;
  }

  void setData(PVector[] pd)
  {
      if(this.enableSave)
      {
        this.created_data.addRow();
        for(int i = 0; i < pd.length; i ++)
        {
          this.created_data.setFloat(this.n_frame_rec, i * 3, pd[i].x);
          this.created_data.setFloat(this.n_frame_rec, i * 3 + 1, pd[i].y);
          this.created_data.setFloat(this.n_frame_rec, i * 3 + 2, pd[i].z);
        }

        this.n_frame_rec ++;
      }
  }

  void saveData()
  {
      this.saveData("motionData");
  }

  void saveData(String name)
  {
      println("[CSVM] Data saved.");
      this.enableSave = false;
      saveTable(this.created_data, "data/created/" + name + ".csv");
  }
  
}
