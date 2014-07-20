#!/usr/bin/env ruby

require "curses"

class TicTacToe

  def initialize
    @field = [
      [' ', ' ', ' '],
      [' ', ' ', ' '],
      [' ', ' ', ' ']
    ]

    @user1 = 'User1'
    @user2 = 'User2'
    @user_input_x = nil
    @user_input_y = nil
    @error_message = nil

    @turn = true

    @judge = nil
  end

  def run
    Curses.curs_set(0)
    Curses.noecho
    until finished?
      render
      @user_input_x = get_valid_input_x
      render
      @user_input_y = get_valid_input_y
      if update_field
        check_result
        @turn = !@turn
      else
        @error_message = "can't overwrite"
      end
      reset_input
    end
  ensure
    Curses.close_screen unless Curses.closed?
    p judge
  end

  private
  def render
    Curses.clear
    Curses.addstr(user_line)
    Curses.addstr(user_input_line)
    Curses.addstr(error_message_line)
    field_output
    @error_message = nil
  end

  def turn_of_user
    @turn ? @user1 : @user2
  end

  def user_line
    "Turn: #{turn_of_user}\n"
  end

  def user_input_line
    line = 'X: '
    unless @user_input_x.nil?
      line = line + @user_input_x
      line = line + ' Y: '
      unless @user_input_y.nil?
        line = line + @user_input_y
      end
    end
    line = line + "\n"
    line
  end

  def error_message_line
    msg = @error_message.nil? ? 'None' : @error_message
    "error: #{msg}\n"
  end

  def field_output
    Curses.addstr("   1 2 3 [X]\n")
    Curses.addstr(" 1 #{@field[0].join(' ')} \n")
    Curses.addstr(" 2 #{@field[1].join(' ')} \n")
    Curses.addstr(" 3 #{@field[2].join(' ')} \n")
    Curses.addstr("[Y]")
  end

  def reset_input
    @user_input_x = nil
    @user_input_y = nil
  end

  def finished?
    @judge.nil? ? false : true
  end

  def judge
    case @judge
    when 'o'
      "winner: #{@user1}"
    when 'x'
      "winner: #{@user2}"
    when 'd'
      "draw"
    end
  end

  def get_valid_input_x
    until valid_point?(input = Curses.getch)
      @error_message = 'should 1, 2 or 3'
      render
    end
    input
  end
  alias :get_valid_input_y :get_valid_input_x

  def update_field
    val = @turn ? 'o' : 'x'
    y = @user_input_y.to_i - 1
    x = @user_input_x.to_i - 1
    if @field[y][x] == ' '
      @field[y][x] = val
      return true
    end
    false
  end

  VALID_POINT = %w[1 2 3]
  def valid_point?(point)
    VALID_POINT.include?(point)
  end

  def check_result
    @field.each do |cols|
      if (cols.uniq.length == 1) && cols[0] != ' '
        @judge = cols[0]
        return
      end
    end

    0.upto(2).each do |idx|
      rows = @field.map {|row| row[idx]}
      if (rows.uniq.length == 1) && rows[0] != ' '
        @judge = rows[0]
        return
      end
    end

    slant = [@field[0][0], @field[1][1], @field[2][2]]
    if (slant.uniq.length == 1) && slant[0] != ' '
      @judge = slant[0]
      return
    end
    slant = [@field[0][2], @field[1][1], @field[2][0]]
    if (slant.uniq.length == 1) && slant[0] != ' '
      @judge = slant[0]
      return
    end

    unless @field.flatten.include?(' ')
      @judge = 'd'
    end
  end

end

app = TicTacToe.new
app.run
