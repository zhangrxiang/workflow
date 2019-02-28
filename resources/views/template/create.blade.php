@extends('layouts.app')

@section('content')
    <div class="container">
        <div class="row">
            <h3>新建模板</h3>
            <form action="{{route('template.store')}}" method="POST">
                <div class="form-group">
                    <label>模板名称</label>
                    <input type="text" class="form-control" name="template_name" placeholder="模板名称">
                </div>

                <!-- <div class="form-group">
                  <label for="exampleInputPassword1">是否显示</label>
                  <label class="radio-inline">
                  <input type="radio" name="is_show"  value="1"> 是
                  </label>
                  <label class="radio-inline">
                  <input type="radio" name="is_show" value="0"> 否
                  </label>
                </div> -->

                {{csrf_field()}}
                <button type="submit" class="btn btn-default">确定</button>
            </form>
        </div>
    </div>
@endsection
