using System;

namespace TestNamespace {
  public class CloseableResource
  {
    private string _state = "Open";
    private string _disposed = "No";

    public string State 
    {
      get 
      {
        return _state;
      }
    }

    public string Disposed
    {
      get 
      {
        return _disposed;
      }
    }

    public void Close()
    {
      _state = "Closed";
    }

    public void Dispose()
    {
      _disposed = "Yes";
    }

  }
}