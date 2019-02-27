<?php

namespace App\Http\Controllers;

use App\Entry,
    App\Proc,
    App\Flow;
use Illuminate\Support\Facades\Auth;

class HomeController extends Controller
{

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //我的申请
        $entries = Entry::with([
            "emp",
            "procs" => function ($query) {
                $query->orderBy("id", 'DESC')->take(1);
            },
            "process"
        ])
            ->where('emp_id', Auth::id())
            ->where('pid', 0)
            ->orderBy('id', 'DESC')
            ->get();
        //我的待办
        $procs = Proc::with([
            "emp",
            "entry" => function ($query) {
                $query->with("emp");
            }])
            ->where('emp_id', Auth::id())
            ->where('status', 0)
            ->orderBy("is_read", "ASC")
            ->orderBy("status", "ASC")
            ->orderBy("id", "DESC")
            ->get();

        //工作流 分组TODO
        $flows = Flow::where([
            'is_publish' => 1,
            'is_show' => 1
        ])
            ->orderBy('id', 'ASC')
            ->get();

        $handle_procs = Proc::with([
            "emp",
            "entry" => function ($query) {
            $query->with("emp");
        }])
            ->where('emp_id', Auth::id())
            ->where('status', '!=', 0)
            ->orderBy('entry_id', 'DESC')
            ->orderBy("id", "ASC")
            ->get()
            ->groupBy('entry_id');

        return view('home')->with(compact("entries", "procs", "flows", "handle_procs"));
    }
}
