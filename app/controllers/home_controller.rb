class HomeController < ApplicationController

  def index

  end

  def import
    if params[:file].present?
      begin
        ladies = []
        gents = []
        @others = []
        f = File.new(params[:file].path)
        xlsx = Roo::Spreadsheet.open(f)
        xlsx.default_sheet = xlsx.sheets.first
        if xlsx.sheets.count == 1
          # row attributes - "NO, NAME, GEN, AGE, CELL, EMAIL, CENTER"
          header_column = {no: "NO", name: "NAME", gender: "GEN", age: "AGE", cell: "CELL", email: "EMAIL", center: "CENTER"}
          xlsx.each_with_index(header_column) do |row, index|
            # {:no=>1, :name=>"AANYA HARSH MEHTA", :gender=>"Female", :age=>nil, :cell=>9892623541, :email=>"Harshmehta24@gmail.com", :center=>"Mumbai"}
            next if index == 0
            # blank row check
            if check_row_is_blank(row)
              next
            elsif row[:gender] == 'Female' || row[:gender] == 'female' || row[:gender] == 'FEMALE' || row[:gender] == 'F' || row[:gender] == 'f'
              row[:gender].upcase! if row[:gender].present?
              ladies << row
            elsif row[:gender] == 'Male' || row[:gender] == 'male' || row[:gender] == 'MALE' || row[:gender] == 'M' || row[:gender] == 'm'
              row[:gender].upcase! if row[:gender].present?
              gents << row
            else
              row[:gender].upcase! if row[:gender].present?
              @others << row
            end
          end
        end


        ladies.sort_by!{|hsh| hsh[:age].to_i}
        gents.sort_by!{|hsh| hsh[:age].to_i}
        @others.sort_by!{|hsh| hsh[:age].to_i}
        ladies.reverse!
        gents.reverse!
        @others.reverse!

        oag_conditions = {
            1 => [3, 'l'],
            2 => [3, 'l'],
            3 => [3,'l'],
            4 => [3, 'g'],
            5 => [2, 'g'],
            6 => [2, 'g'],
            11 => [1, 'g'],
            16 => [3, 'g'],
            19 => [3, 'l'],
            20 => [3, 'l'],
            21 => [3, 'l'],
            22 => [3, 'l'],
            23 => [2, 'l'],
            25 => [2, 'g']
        }

        nag_conditions = {
            39 => [3, 'l'],
            40 => [3, 'l'],
            41 => [3, 'l'],
            42 => [3, 'l'],
            43 => [2, 'g'],
            49 => [3, 'l'],
            50 => [3, 'l'],
            51 => [3, 'l'],
            52 => [3, 'l'],
            53 => [3, 'l'],
            54 => [3, 'g'],
            55 => [2, 'g'],
            57 => [3, 'g'],
            58 => [3, 'g'],
            59 => [3, 'g'],
            60 => [3, 'g']
        }

        nag_conditions_for_extra = {
            39 => [4, 'l'],
            40 => [4, 'l'],
            41 => [4, 'l'],
            42 => [4, 'l'],
            43 => [3, 'g'],
            49 => [4, 'l'],
            50 => [4, 'l'],
            51 => [4, 'l'],
            52 => [4, 'l'],
            53 => [4, 'l'],
            54 => [4, 'g'],
            55 => [3, 'g'],
            57 => [4, 'g'],
            58 => [4, 'g'],
            59 => [4, 'g'],
            60 => [4, 'g']
        }

        # 37 => [3, 'l'], #ac
        # 38 => [3, 'l'], #ac
        # 45 => [3, 'g'], #ac
        # 46 => [3, 'g'], #ac
        # 47 => [3, 'g'], #ac
        # 48 => [3, 'g'], #ac

        count  = 0
        @oag_allocation = {}
        @nag_allocation = {}
        total = (ladies.present? ? ladies.length : 0) + (gents.present? ? gents.length : 0) + (@others.present? ? @others.length : 0)
        oag_conditions.each do |room, condition|

          if count <= total
            roomiez = []
            roomiez = ladies[0..condition[0]] if condition[1] == 'l' || gents.blank?
            roomiez = gents[0..condition[0]] if (condition[1] == 'g' || ladies.blank?) && roomiez.blank?

            @oag_allocation[room] = roomiez
            (condition[0]+1).times {
              ladies.delete_at(0)
              count += 1
            } if roomiez.present? && roomiez[0][:gender] == "FEMALE" # if condition[1] == 'l'

            (condition[0]+1).times {
              gents.delete_at(0)
              count += 1
            } if roomiez.present? && roomiez[0][:gender] == "MALE" # if condition[1] == 'g'

          else
            break
          end
        end
        if total > 52
          remaining = total - 52
          if remaining > 62
            nag_conditions_for_extra.each do |room, condition|
              roomiez = ladies[0..condition[0]] if condition[1] == 'l' || gents.blank?
              roomiez = gents[0..condition[0]] if (condition[1] == 'g' || ladies.blank?) && roomiez.nil?
              roomiez.each do |roomie|
                newarr = Array.new
                newarr << roomie
                roomiez - newarr if roomie[:age] > 35
              end

              @nag_allocation[room] = roomiez
              (condition[0]+1).times { ladies.delete_at(0) } if roomiez.present? && roomiez[0][:gender] == "FEMALE" # if condition[1] == 'l'
              (condition[0]+1).times { gents.delete_at(0) } if roomiez.present? && roomiez[0][:gender] == "MALE" # if condition[1] == 'g'
            end
          else
            nag_conditions.each do |room, condition|
              roomiez = ladies[0..condition[0]] if condition[1] == 'l' || gents.blank?
              roomiez = gents[0..condition[0]] if (condition[1] == 'g' || ladies.blank?) && roomiez.nil?

              @nag_allocation[room] = roomiez
              (condition[0]+1).times { ladies.delete_at(0) } if roomiez.present? && roomiez[0][:gender] == "FEMALE" # if condition[1] == 'l'
              (condition[0]+1).times { gents.delete_at(0) } if roomiez.present? && roomiez[0][:gender] == "MALE" # if condition[1] == 'g'
            end
          end
        end
        render 'result'
      end
    end
  end

  private

  def check_row_is_blank(row)
    row_blank = true
    row.each do |k, v|
      unless v.blank?
        row_blank = false
        break
      end
    end
    return row_blank
  end

end
