using System;

namespace D3Plot {
    public class UnsupportedFeatureException : Exception {
        public UnsupportedFeatureException() {}
        public UnsupportedFeatureException(string message) : base(message) {}
    }
    
    public class StateDatabaseNotSetException : Exception {
        public StateDatabaseNotSetException() {}
    }
}