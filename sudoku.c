#include <stdio.h>

int board[9][9] = {
                    {9, 0, 0, 1, 0, 0, 0, 0, 5},
                    {0, 0, 5, 0, 9, 0, 2, 0, 1},
                    {8, 0, 0, 0, 4, 0, 0, 0, 0},
                    {0, 0, 0, 0, 8, 0, 0, 0, 0},
                    {0, 0, 0, 7, 0, 0, 0, 0, 0},
                    {0, 0, 0, 0, 2, 6, 0, 0, 9},
                    {2, 0, 0, 3, 0, 0, 0, 0, 6},
                    {0, 0, 0, 2, 0, 0, 9, 0, 0},
                    {0, 0, 1, 9, 0, 4, 5, 7, 0}
                  };

void display()
{

    printf("\e[1;1H\e[2J");
    printf("\033[1;30m");
    int i, j;
    for (i = 0; i < 9; i++)
    {
        if (i % 3 == 0 && i != 0)
        {
            printf("\033[1;31m");
            for (j = 0; j < 9; j++)
                printf("+---");
            printf("+\033[1;30m\n");
        }
        else
        {
            for (j = 0; j < 9; j++)
            {
                if (j % 3 == 0 && j != 0)
                    printf("\033[1;31m+\033[1;30m---");
                else
                    printf("+---");
            }
            printf("+\n");
        }
        for (j = 0; j < 9; j++)
        {
            if (j % 3 == 0 && j != 0)
                printf("\033[1;31m| \033[1;32m%d\033[1;30m ", board[i][j]);
            else
                printf("| \033[1;32m%d\033[1;30m ", board[i][j]);
        }
        printf("|\n");
    }
    for (j = 0; j < 9; j++)
    {
        if (j % 3 == 0 && j != 0)
            printf("\033[1;31m+\033[1;30m---");
        else
            printf("+---");
    }
    printf("+\n");
}

int check_row(int row, int val)
{
    int i;
    for (i = 0; i < 9; i++)
    {
        if (board[row][i] == val)
            return 0;
    }
    return 1;
}

int check_column(int column, int val)
{
    int i;
    for (i = 0; i < 9; i++)
    {
        if (board[i][column] == val)
            return 0;
    }
    return 1;
}

int check_block(int row, int column, int val)
{
    int tmp_r = row - row % 3;
    int tmp_c = column - column % 3;
    int i;
    int j;
    for (i = tmp_r; i < tmp_r + 3; i++)
    {
        for (j = tmp_c; j < tmp_c + 3; j++)
        {
            if (board[i][j] == val)
                return 0;
        }
    }
    return 1;
}

int solve(int pos)
{
    if (pos == 81)
        return 1;

    int i;

    int row = pos / 9;
    int column = pos % 9;

    if (board[row][column] == 0)
    {
        for (i = 1; i <= 9; i++)
        {
            if (check_row(row, i) && check_column(column, i) && check_block(row, column, i))
            {
                board[row][column] = i;
                if(solve(pos + 1))
                    return 1;

                board[row][column] = 0;
            }
        }
    }
    else
    {
        if(solve(pos + 1))
            return 1;
    }
    return 0;
}

int main()
{
    if(!solve(0))
        printf("Can't be solve !\n");
    else
        display();
    return 0;
}
