// Generated by CoffeeScript 1.11.1
(function() {
  var Progress, React,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  React = require('react');

  Progress = (function(superClass) {
    extend(Progress, superClass);

    function Progress(props) {
      this.render = bind(this.render, this);
      Progress.__super__.constructor.call(this, props);
    }

    Progress.prototype.render = function() {
      var div;
      div = React.DOM.div;
      console.log("progress bar " + this.props.done + "/" + this.props.total + " (running: " + this.props.running + ")");
      return div({
        style: {
          width: '100%',
          flex: '0 0 0.5em',
          height: '0.8em',
          border: 'none',
          backgroundColor: '#000',
          display: this.props.running ? 'block' : 'none',
          zIndex: 100000
        }
      }, [
        div({
          style: {
            width: (this.props.done * 100 / this.props.total) + '%',
            backgroundColor: '#00f',
            height: '100%'
          },
          key: 0
        }, ''), div({
          style: {
            right: '0px',
            bottom: '0px',
            color: '#99f',
            backgroundColor: 'rgba(0,0,0,0)',
            display: this.props.running,
            position: 'absolute'
          },
          key: 1
        }, this.props.done + '/' + this.props.total)
      ]);
    };

    return Progress;

  })(React.Component);

  module.exports = React.createFactory(Progress);

}).call(this);

//# sourceMappingURL=progress.js.map
